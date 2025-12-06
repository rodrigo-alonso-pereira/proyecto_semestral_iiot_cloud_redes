import gpio
import net
import mqtt
import encoding.json
import esp32
import system 
import system.containers as containers
import location
import net.wifi as wifi

// Importación de módulos locales
import.utilities
import.sensors
import.config

main:
  print "Iniciando secuencia de telemetría..."

  try:
    /* FASE 1: Configuración e Inicialización */

    // Instanciacion de sensores
    moisture_sensor  := MoistureSensor (gpio.Pin PIN_SENSOR_MOISTURE) // Inicializar sensor de humedad del suelo
    temp_hum_sensor   := TempAndHumSensor (gpio.Pin PIN_SENSOR_DHT11) // Inicializar sensor DHT11
    light_sensor    := LightSensor (gpio.Pin PIN_SENSOR_LIGHT) // Inicializar sensor de luz
    
    // Instanciacion muestreadores en ráfaga
    sampler_moisture := BurstSampler moisture_sensor // Inicializar muestreador de humedad del suelo
    sampler_temp_hum := BurstSampler temp_hum_sensor // Inicializar muestreador de temperatura y humedad
    sampler_light := BurstSampler light_sensor // Inicializar muestreador de sensor de luz

    // Configuracion del cliente MQTT
    client := mqtt.Client --host=MQTT-HOST // Crear cliente MQTT
    options := mqtt.SessionOptions
        --client-id=MQTT-CLIENT-ID
        --username=MQTT-USERNAME
        --password=MQTT-PASSWORD
    client.start --options=options // Iniciar conexión MQTT (con autenticación)

    // Configuracion de location
    location := location.Location LATITUD_DEVICE LONGITUD_DEVICE

    while true:
      /* FASE 2: Adquisición y Procesamiento de Datos del ESP32 */

      // Se escanea la red WiFi antes de cada adquisición
      access_points := wifi.scan SCAN_CHANNELS --period-per-channel-ms=120
      rssi_val := -100 // Valor por defecto si no se encuentra la red
 
      access_points.do: | ap/wifi.AccessPoint | // Iterar sobre los puntos de acceso
        if ap.ssid == "Mundo 410":
          rssi_val = ap.rssi // Capturar el valor RSSI
      
      // Estadísticas del sistema
      process_stats := system.process_stats
      memoria_usada_b := process_stats[1] // Index 1: Lo que tus variables pesan
      memoria_reservada_b := process_stats[2]  // Index 2: Lo que tu proceso abarca
      memoria_sistema_libre_b := process_stats[7]  // Index 7: Lo que el sistema tiene libre

      // Contenedores cargados
      lista_imagenes := containers.images

      // Tiempo total de ejecución
      total_run_time := esp32.total-run-time / 1_000_000 // en segundos
      
      /* FASE 3: Muestreo en Ráfaga de Sensores (Adquisición) */

      print "[ACQ] Adquiriendo ráfagas de $(BURST_COUNT) muestras..."
      
      raw_moisture := sampler_moisture.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read
      temperature_amb_celcius := sampler_temp_hum.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read
      humidity_amb_percentage := sampler_temp_hum.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read_humidity
      raw_light := sampler_light.sample --count=BURST_COUNT --delay_ms=BURST_DELAY_MS: it.read
      
      // Humedad del suelo: Filtrado híbrido (promedio)
      filtered_moisture := SignalProcessor.average raw_moisture
      percentage_filtered := map_range filtered_moisture VALOR_AIRE VALOR_AGUA 0.0 100.0

      // Temperatura ambiental: Mediana para ignorar picos rápidos.
      filtered_temperature := SignalProcessor.median temperature_amb_celcius
      
      // Humedad ambiental: Promedio para suavizar variaciones lentas.
      filtered_humidity := SignalProcessor.average humidity_amb_percentage

      // Luz ambiental: Promedio para suavizar variaciones lentas.
      filtered_light := SignalProcessor.median raw_light
      lux_filtered := filtered_light * 200.0
      light_percentage := (filtered_light / VALOR_LUZ) * 100.0

      print "  Humedad suelo (raw): $(%.2f filtered_moisture) y Porcentaje promedio: $(%.2f percentage_filtered)%"
      print "  Temperatura ambiental (mediana): $(%.2f filtered_temperature) °C"
      print "  Humedad ambiental (promedio): $(%.2f filtered_humidity)%"
      print "  Luz ambiental (mediana): $(%.2f lux_filtered) lx y Porcentaje: $(%.2f light_percentage)%"
      print "  RSSI de 'Mundo 410': $rssi_val dBm"
      print "  Locación GPS: Latitud $(location.latitude), Longitud $(location.longitude)"
      print "  Memoria Usada: $(memoria_usada_b) bytes, Reservada: $(memoria_reservada_b) bytes, Sistema Libre: $(memoria_sistema_libre_b) bytes"
      print "  Contenedores Cargados: $(lista_imagenes.size)"
      print "  Total Run Time: $(total_run_time) seconds"
      
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
          "temperature_celsius": filtered_temperature,
          "lux": lux_filtered,
          "light_percentage": light_percentage
        },
        "metrics_device": {
          "rssi_dbm": rssi_val,
          "latitude": location.latitude,
          "longitude": location.longitude,
          "memory_used_bytes": memoria_usada_b,
          "memory_reserved_bytes": memoria_reservada_b,
          "memory_system_free_bytes": memoria_sistema_libre_b,
          "containers_loaded": lista_imagenes.size,
          "total_run_time_seconds": total_run_time
        },
        "processing": {
          "samples_per_burst": BURST_COUNT,
          "filter_method": "hybrid_median_avg"
        }
      }

      /* FASE 4: Publicación y Espera */
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