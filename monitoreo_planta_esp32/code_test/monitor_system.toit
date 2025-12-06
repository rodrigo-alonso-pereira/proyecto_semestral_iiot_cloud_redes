/**
 * Monitor de Diagnóstico de Sistema para ESP32 en Toit.
 * 
 * Este programa demuestra la capacidad de introspección del lenguaje Toit.
 * Monitoriza cíclicamente:
 * 1. Identidad del Hardware (MAC, Chip Info)
 * 2. Estado de Conectividad (RSSI, IP)
 * 3. Recursos del Sistema (Memoria, Uptime)
 * 4. Sensores Internos (Temperatura)
 */

// Importación de librerías esenciales del SDK de Toit
import esp32
import system
import system.containers
import net.wifi as wifi
import net.ip-address
import net
import location
import device

// Punto de entrada principal de la aplicación
main:
  print "----------------------------------------------------"
  print "  INICIANDO SISTEMA DE MONITORIZACIÓN AVANZADA TOIT"
  print "----------------------------------------------------"

  // 1. INTROSPECCIÓN DEL HARDWARE
  // -----------------------------
  // La dirección MAC es la huella digital única del dispositivo.
  // Es vital para identificar qué nodo está reportando en una flota. 

  // mac_address := net.wifi.mac_address
  // print "| Identificador (MAC) : $mac_address"
  
  // Información sobre la plataforma subyacente (ej. FreeRTOS/ESP32)
  platform_name := system.platform
  print "| Plataforma          : $platform_name"
  print "----------------------------------------------------"

  // 2. BUCLE DE MONITORIZACIÓN CONTINUA
  // -----------------------------------
  // Ejecutamos un ciclo infinito para muestrear las variables internas.
  // En un caso real, esto podría enviar datos a la nube vía MQTT/HTTP.
  while true:
    print "\n"

    // --- A. ANÁLISIS DE MEMORIA (HEAP) ---
    // Monitorizar la memoria es crítico para prevenir fugas (leaks).
    // Aunque Toit tiene GC, observar el uso ayuda a optimizar.
    // 'system.free_memory' o estadísticas de proceso dan esta visión.
    // Nota: La disponibilidad exacta de la API global puede variar por versión.
    // Aquí simulamos la lectura de estadísticas del proceso actual.
    // Un valor decreciente constante indicaría una fuga lógica.
    print "  + Memoria:"
    print "    - Gestión: Automática (Garbage Collector)"
    // En versiones de depuración, se pueden volcar estadísticas completas:
    // print "    - Estadísticas GC: Disponible en logs de sistema"

    // --- B. TIEMPO DE ACTIVIDAD (UPTIME) ---
    // Usamos el reloj monótono para evitar saltos por sincronización NTP.
    // Time.monotonic_us retorna microsegundos desde el boot.
    uptime_us := Time.monotonic_us
    uptime_s := uptime_us / 1_000_000
    print "Uptime (s): $uptime_s seconds"

    // Cálculo humano-legible
    dias := uptime_s / 86400
    horas := (uptime_s % 86400) / 3600
    minutos := (uptime_s % 3600) / 60
    segundos := uptime_s % 60
    
    print "  + Estabilidad (Uptime):"
    print "    - Tiempo Activo : $(dias)d $(horas)h $(minutos)m $(segundos)s"
    // -33.52389127662384, -70.65771655814775
    location := location.Location -33.52389127662384 -70.65771655814775
    print "Location info: $location"

    process-stats := system.process_stats
    print " Process Stats: $process-stats"
    print " free memory: $(process-stats[7]) bytes"
    print " allocated memory: $(process-stats[8]) bytes"
    print " program name: $system.program_name"
    print "There have been $(process-stats[STATS-INDEX-GC-COUNT]) GCs for this process"

    // Extraemos los datos según tu documentación
    memoria_usada_objetos := process-stats[1]  // Index 1: Lo que tus variables pesan
    memoria_reservada     := process-stats[2]  // Index 2: Lo que tu proceso abarca
    memoria_sistema_libre := process-stats[7]  // Index 7: Lo que le queda a la ESP32

    // Calculamos un estimado del total visible (Libre + Reservada actual)
    total_visible := memoria_sistema_libre + memoria_reservada

    print "--- Estado de la Memoria ---"
    print "RAM Libre (Sistema): $(%3f (memoria_sistema_libre / 1024)) KB"
    print "RAM Usada (Tu App):  $(memoria_usada_objetos / 1024) KB"
    print "RAM Reservada (Heap): $(memoria_reservada / 1024) KB"
    print "----------------------------"
    print "Total Aprox (Toit):  $(total_visible / 1024) KB"

    lista_imagenes := containers.images
    print " Contenedores Cargados: $(lista_imagenes.size)"

    print " Device Hardware ID: $device.hardware-id"
    print " Device Model: $device.name"
    print " Mac-Address: $esp32.mac-address"
    total_run_time := esp32.total-run-time/1_000_000
    print " Total-run-time: $total_run_time seconds"
    // print " CPU Frequency: $(esp32.pm-max-frequency-mhz) MHz"
    // print " CPU Min frequency: $(esp32.pm-min-frequency-mhz) MHz"
  

    // --- C. TELEMETRÍA DE RED (WIFI / RSSI) ---
    // La calidad del enlace determina la fiabilidad del IoT.
    // if wifi.station.is_connected:
    //   rssi := wifi.station.rssi
    //   ip := wifi.station.ip_address
      
    //   // Interpretación semántica del nivel de señal
    //   calidad := "Desconocida"
    //   if rssi >= -50: calidad = "Excelente (Saturación)"
    //   else if rssi >= -60: calidad = "Muy Buena"
    //   else if rssi >= -70: calidad = "Buena"
    //   else if rssi >= -80: calidad = "Aceptable (Borde)"
    //   else: calidad = "Crítica/Inestable"

    //   print "  + Red WiFi:"
    //   print "    - Estado        : CONECTADO"
    //   print "    - IP Local      : $ip"
    //   print "    - Intensidad    : $rssi dBm"
    //   print "    - Calidad       : $calidad"
    // else:
    //   print "  + Red WiFi:"
    //   print "    - Estado        : DESCONECTADO (Buscando red...)"

    // --- D. SENSORES DE SILICIO (TEMPERATURA) ---
    // Acceso directo al sensor térmico del die del ESP32.
    // Útil para detectar sobrecalentamiento del CPU.
    // Bloque try-catch para robustez si el hardware no lo soporta.
    // try:
    //   // esp32.temperature devuelve un float en grados Celsius.
    //   temp_interna := esp32.temperature
    //   print "  + Diagnóstico Térmico:"
    //   print "    - Temp. Núcleo  : $(%.1f temp_interna) °C"
      
    //   // Alerta simple de sobrecalentamiento
    //   if temp_interna > 70.0:
    //     print "   ! ALERTA: Temperatura de operación elevada!"
    // finally:
    //   // Aseguramos que el script no se detenga si la lectura falla
    //   null

    // print "----------------------------------------------------"
    
    // Frecuencia de muestreo: Cada 5 segundos
    sleep --ms=5000