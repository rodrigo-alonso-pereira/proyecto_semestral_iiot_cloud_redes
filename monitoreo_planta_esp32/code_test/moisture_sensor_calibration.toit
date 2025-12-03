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

  while true:
    // adc.get lee el valor ADC de 12 bits (0-4095)
    valor_bruto := adc.get
    print "Valor Bruto Actual: $valor_bruto"
    sleep --ms=1000 // Pausa de 1 segundo