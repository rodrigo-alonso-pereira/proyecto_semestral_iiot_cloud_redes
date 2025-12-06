import gpio
import gpio.adc

// Pin del Sensor de Luz (Debe ser ADC1: 32, 33, 34, 35, 36, 39)
PIN_SENSOR ::= 35

// Datos de calibracion
VALOR_OSCURIDAD ::= 0.14199999999999998734
VALOR_LUZ ::= 3.1450000000000000178

main:
  
  // Configurar el sensor analógico
  pin := gpio.Pin PIN_SENSOR
  sensor := adc.Adc pin 

  while true:
    voltaje := sensor.get
    //voltaje := vol_raw * 0.0008056640625 // Conversión a voltaje (3.3V / 4095)
    // print "Voltaje bruto : $voltaje"

    // --- Cálculos Físicos ---
    // Fórmula derivada de tu código original:
    // amps := voltaje / 10000
    // microAmps := amps * 1000000
    // lux := microAmps * 2.0
    // Simplificado: Lux = Volts * 200
    lux := voltaje * 200.0

    // Porcentaje (Asumiendo 3.3V como máximo en ESP32)
    // En Arduino usabas * 0.0976 (aprox 100/1024). Aquí usamos voltaje directo.
    porcentaje := (voltaje / VALOR_LUZ) * 100.0

    // Limitar el porcentaje a 100%
    if porcentaje > 100.0: porcentaje = 100.0

    // Debug en consola serial (visible con 'jag monitor')
    print "V: $(%.2f voltaje) -> $(%.1f lux) lx -> $(%.2f porcentaje)%"

    // Pausa no bloqueante (permite que el WiFi siga funcionando)
    sleep --ms=5000