import gpio
import gpio.adc

// Use un pin ADC1 (GPIO 32-39). GPIO 34 es recomendado.
PIN_SENSOR ::= 34

main:
  pin := gpio.Pin PIN_SENSOR
  adc := adc.Adc pin

  print "Iniciando script de calibración del sensor..."
  print "Pin del sensor: $PIN_SENSOR"
  print "---"
  print "1. Sostenga el sensor completamente AL AIRE (seco)."
  print "   Anote el valor como 'VALOR_AIRE'."
  print "2. Sumerja el sensor en un vaso de AGUA (húmedo)."
  print "   Anote el valor como 'VALOR_AGUA'."
  print "---"

  count := 0
  muestras := []

  while true:
    // adc.get lee el valor ADC de 12 bits (0-4095)
    valor_bruto := adc.get
    print "Valor Bruto Actual: $valor_bruto"
    muestras.add valor_bruto
    count += 1
    sum := muestras.reduce --initial=0: | acc el | acc + el
    promedio := sum.to_float / count.to_float
    print "Muestras tomadas: $count, Promedio Actual: $promedio"
    sleep --ms=25 // Pausa de 25 milisegundos