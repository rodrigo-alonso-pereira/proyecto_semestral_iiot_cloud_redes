import watchdog.provider
import watchdog show WatchdogServiceClient

main:
  // Iniciar el proveedor de watchdog.
  provider.main

  // Crear un cliente de watchdog.
  client := WatchdogServiceClient
  // Conectar al proveedor que ha sido iniciado anteriormente.
  client.open

  // Crear un watchdog.
  dog := client.create "usach.redes.monitoreo_planta_esp32"

  // Requerir alimentación cada 90 segundos.
  dog.start --s=90

  // Alimentarlo:
  dog.feed

  // Detenerlo, si no es necesario:
  dog.stop

  // Cuando está detenido, cerrarlo.
  dog.close

  print "done"
