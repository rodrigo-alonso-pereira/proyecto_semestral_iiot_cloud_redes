// --- Constantes de Configuración ---
PIN_SENSOR_MOISTURE ::= 34 // Pin ADC1 (GPIO 32-39)
PIN_SENSOR_DHT11 ::=  32 // Pin para DHT11
MQTT_CLIENT_ID ::= "esp32_01" // ID del cliente MQTT
MQTT_HOST ::= "mqtt.fabricainteligente.cl" // Broker público de MQTT
MQTT_TOPIC ::= "usach/redes/data" // Topico MQTT productivo
//MQTT_TOPIC ::= "usach_redes/test" // Topico MQTT para publicar datos sin guardar en bd
MQTT_USERNAME ::= "usach_redes" // Nombre de usuario MQTT
MQTT_PASSWORD ::= "usachredes" // Contraseña MQTT

// Datos de calibracion 
VALOR_AIRE ::= 2.2269999999999998685 // Alto valor ADC (seco) -> Mapea a 0%
VALOR_AGUA ::= 0.89000000000000001332 // Bajo valor ADC (húmedo) -> Mapea a 100%

// Configuración de Adquisición
BURST_COUNT    ::= 100   // Cantidad de muestras para estadística
BURST_DELAY_MS ::= 25   // Tiempo entre muestras (ms)
FREQUENCY_MS  ::= 60000 // 1 minuto de intervalo entre envíos de datos (ms)