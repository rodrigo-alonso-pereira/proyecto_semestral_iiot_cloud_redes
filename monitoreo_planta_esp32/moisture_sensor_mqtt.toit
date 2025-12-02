import gpio // Toit GPIO library
import gpio.adc // Toit ADC library
import dhtxx // Toit DHTxx sensor library
import mqtt // Toit MQTT library
import encoding.json // Toit JSON encoding library

// --- Constantes de Configuración ---
PIN_SENSOR_MOISTURE ::= 34 // Pin ADC1 (GPIO 32-39)
PIN_SENSOR_DHT11 ::=  32 // Pin para DHT11
CLIENT_ID ::= "lab_1" // Dejar vacío para generar uno aleatorio
HOST ::= "mqtt.fabricainteligente.cl" // Broker público de MQTT
TOPIC ::= "usach/test/humedad" // Tema MQTT para publicar datos
//TOPIC ::= "usach_redes/test" // Tema MQTT para publicar datos
USERNAME ::= "usach_redes" // Nombre de usuario MQTT
PASSWORD ::= "usachredes" // Contraseña MQTT

// Datos de calibracion 
VALOR_AIRE ::= 2.2269999999999998685 // Alto valor ADC (seco) -> Mapea a 0%
VALOR_AGUA ::= 0.89000000000000001332 // Bajo valor ADC (húmedo) -> Mapea a 100%

// --- Programa Principal ---
main:
  // Configuración del sensor de humedad del suelo (sensor resistivo)
  pin := gpio.Pin PIN_SENSOR_MOISTURE
  adc := adc.Adc pin

  // Configuración del sensor DHT11 (temperatura y humedad ambiental)
  pin_dht11 := gpio.Pin PIN_SENSOR_DHT11
  driver := dhtxx.Dht11 pin_dht11

  // Configuración del cliente MQTT
  client := mqtt.Client --host=HOST // Crear cliente MQTT
  options := mqtt.SessionOptions
      --client-id=CLIENT-ID
      --username=USERNAME 
      --password=PASSWORD
  client.start --options=options // Iniciar conexión MQTT (con autenticación)

  print "Iniciando monitor de planta..."
  print "Pin HUMEDAD_SUELO: $PIN_SENSOR_MOISTURE"
  print "Pin TEMPERATURA_HUMEDAD_AMBIENTAL: $PIN_SENSOR_DHT11"
  print "Conectando al broker MQTT en '$HOST' y publicando en el topico: '$TOPIC'"

  while true:
    /* Sensor de humedad del suelo */
    valor_bruto := adc.get //Valor medido por el sensor

    // Mapear el valor bruto a un porcentaje (0.0 a 100.0 | seco a húmedo)
    porcentaje_raw := map_range valor_bruto VALOR_AIRE VALOR_AGUA 0.0 100.0

    // Restringir el valor entre 0 y 100 (Clamping) evitar valores fuera de rango
    porcentaje := max 0.0 (min 100.0 porcentaje_raw)

    /* Sensor de temperatura y humedad ambiental */
    temperatura_ambiental := driver.read.temperature
    humedad_ambiental := driver.read.humidity

    /* Publicación MQTT */
    payload := json.encode {  // Crear payload JSON
      "humedad_suelo_bruto": valor_bruto, 
      "humedad_suelo_porcentaje": porcentaje,
      "temperatura_ambiental_celsius": temperatura_ambiental,
      "humedad_ambiental_porcentaje": humedad_ambiental
    }
    client.publish TOPIC payload // Publicar datos en el tópico MQTT
    sleep --ms=5000 // Leer cada 5 segundos
  
  client.close // Cerrar conexión MQTT al finalizar (nunca se alcanza aquí)


// --- Función de Utilidad (Traducción de map() de Arduino) ---
map_range value in_min in_max out_min out_max:
  value_float := value.to_float // valor sensor actual
  in_min_float := in_min.to_float // valor seco (VALOR_AIRE)
  in_max_float := in_max.to_float // valor húmedo (VALOR_AGUA)
  out_min_float := out_min.to_float // 0.0
  out_max_float := out_max.to_float // 100.0

  // Manejar división por cero si in_min == in_max
  if in_min_float == in_max_float: return out_min_float

  // Fórmula de mapeo lineal (interpolación)
  return (value_float - in_min_float) * (out_max_float - out_min_float) / (in_max_float - in_min_float) + out_min_float