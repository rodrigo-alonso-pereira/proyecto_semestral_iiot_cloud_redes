// main.toit
import gpio
import net
import mqtt
import encoding.json
import esp32 // Necesario para deep sleep 

// Importación de módulos locales
import.utilities
import.sensors
import.config

main:
  print "Iniciando secuencia de telemetría..."

  try:
    // Instanciacion de sensores
    moisture_sensor  := MoistureSensor (gpio.Pin PIN_SENSOR_MOISTURE) // Inicializar sensor de humedad del suelo
    temp_hum_sensor   := TempAndHumSensor (gpio.Pin PIN_SENSOR_DHT11) // Inicializar sensor DHT11
    //light_sensor := SimulatedLightSensor
    
    // Instanciacion muestreadores en ráfaga
    sampler_moisture := BurstSampler moisture_sensor // Inicializar muestreador de humedad del suelo
    sampler_temp_hum := BurstSampler temp_hum_sensor // Inicializar muestreador de temperatura y humedad
    //sampler_l := BurstSampler light_sensor

    // Configuracion del cliente MQTT
    client := mqtt.Client --host=MQTT-HOST // Crear cliente MQTT
    options := mqtt.SessionOptions
        --client-id=MQTT-CLIENT-ID
        --username=MQTT-USERNAME
        --password=MQTT-PASSWORD
    client.start --options=options // Iniciar conexión MQTT (con autenticación)

    while true:
    
      // 3. Fase de Muestreo en Ráfaga (Adquisición)
      print "[ACQ] Adquiriendo ráfagas de $(BURST_COUNT) muestras..."
      
    
      raw_moisture := sampler_moisture.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read
      temperature_amb_celcius := sampler_temp_hum.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read
      humidity_amb_percentage := sampler_temp_hum.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read_humidity
      //raw_light := sampler_l.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS
      
      // Humedad del suelo: Filtrado híbrido (promedio)
      filtered_moisture := SignalProcessor.average raw_moisture
      percentage_filtered := map_range filtered_moisture VALOR_AIRE VALOR_AGUA 0.0 100.0

      // Temperatura ambiental: Mediana para ignorar picos rápidos.
      filtered_temperature := SignalProcessor.median temperature_amb_celcius
      
      // Humedad ambiental: Promedio para suavizar variaciones lentas.
      filtered_humidity := SignalProcessor.average humidity_amb_percentage

      print "  Humedad suelo (raw): $(%.2f filtered_moisture) y Porcentaje promedio: $(%.2f percentage_filtered)%"
      print "  Temperatura ambiental (mediana): $(%.2f filtered_temperature) °C"
      print "  Humedad ambiental (promedio): $(%.2f filtered_humidity)%"
      
      // Obtener y verificar hora en servidor NTP
      check_ntp_time Time.now
      timestamp_str := Time.now
      print "  Timestamp NTP: $timestamp_str"      
    
      // Armar el payload JSON
      payload := json.encode {
        "@timestamp": "$timestamp_str",
        "device": {
          "id": MQTT_CLIENT_ID,
          "location": "lab-01"
        },
        "metrics": {
          "moisture_raw": filtered_moisture,
          "moisture_percentage": percentage_filtered,
          "humidity_percentage": filtered_humidity,
          "temperature_celsius": filtered_temperature
        },
        "processing": {
          "samples_per_burst": BURST_COUNT,
          "filter_method": "hybrid_median_avg"
        }
      }
      client.publish MQTT_TOPIC payload
      sleep --ms=FREQUENCY_MS // Esperar el intervalo configurado antes de la siguiente lectura.
    
  finally:
    // Aseguramos cierre de la interfaz de red
    //if network_interface: network_interface.close
    //print " Red cerrada."
    

  // 7. Gestión de Energía (Deep Sleep)
  // Calculamos la duración del sueño.
  //sleep_duration := Duration --ms=DEEP_SLEEP_MS
  //print " Entrando en Deep Sleep por $sleep_duration..."
  
  // La función deep_sleep detiene la CPU y apaga periféricos principales.
  // El reinicio posterior será un "reset" completo, ejecutando main desde el inicio.
  //esp32.deep_sleep sleep_duration