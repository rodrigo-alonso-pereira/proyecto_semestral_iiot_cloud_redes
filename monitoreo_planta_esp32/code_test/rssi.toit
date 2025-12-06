// Importación del módulo estándar de Wi-Fi
import net.wifi

// Definición de canales a escanear (Banda 2.4GHz estándar)
SCAN_CHANNELS ::= #[1, 4, 5, 6, 7, 2, 8, 9, 10, 11, 3]

main:
  print "Iniciando escaneo de redes Wi-Fi para telemetría RSSI..."

  try:
    // Ejecución del escaneo. Retorna una lista de objetos wifi.AccessPoint
    // Se configura un tiempo de escucha de 120ms por canal para asegurar captura de beacons.
    access_points := wifi.scan SCAN_CHANNELS --period-per-channel-ms=120

    if access_points.size == 0:
      print "Advertencia: No se detectaron redes. Verifique la antena."
      return

    print "Se encontraron $access_points.size puntos de acceso."
    print "------------------------------------------------"
    print "| SSID | RSSI (dBm) |"
    print "------------------------------------------------"

    // Iteración sobre los resultados para extraer el RSSI
    access_points.do: | ap/wifi.AccessPoint |
      // Acceso directo a la propiedad.rssi
      rssi_val := ap.rssi
      
      // Formateo de salida para análisis
      // Se utiliza el padding de cadenas para alinear la tabla
      if ap.ssid == "Mundo 410":
        print "Intensidad de 'Mundo 410': $(%4d rssi_val) dBm"
      print "| $(%-30s ap.ssid) | $(%4d rssi_val) |"
  finally:
    // val := ap.rssi
