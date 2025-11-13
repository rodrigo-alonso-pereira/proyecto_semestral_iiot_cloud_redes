import gpio
import gpio.adc

// --- Constantes de Configuración ---
PIN_SENSOR ::= 34 // Pin ADC1 (GPIO 32-39)

// Datos de calibracion 
VALOR_AIRE ::= 2.2269999999999998685 // Alto valor ADC (seco) -> Mapea a 0%
VALOR_AGUA ::= 0.89000000000000001332 // Bajo valor ADC (húmedo) -> Mapea a 100%

// --- Programa Principal ---
main:
  pin := gpio.Pin PIN_SENSOR
  adc := adc.Adc pin

  print "Iniciando monitor de humedad del suelo..."
  print "Pin: $PIN_SENSOR"
  print "Calibración"
  print "---"

  while true:
    valor_bruto := adc.get //Valor medido por el sensor

    // Mapear el valor bruto a un porcentaje (0.0 a 100.0)
    // Se usa el rango de entrada INVERSO (VALOR_AIRE a VALOR_AGUA)
    // para mapear al rango de salida (0.0 a 100.0).
    porcentaje_raw := map_range valor_bruto VALOR_AIRE VALOR_AGUA 0.0 100.0

    // Restringir el valor entre 0 y 100 (Clamping)
    // Esto evita valores como -5% o 105% si la lectura
    // se sale ligeramente del rango de calibración.
    porcentaje := 0.0.max (100.0.min porcentaje_raw)

    print "Valor Bruto: $valor_bruto -> Humedad: $(%.2f porcentaje)%"
    
    sleep --ms=2000 // Leer cada 2 segundos


// --- Función de Utilidad (Traducción de map() de Arduino) ---
map_range value in_min in_max out_min out_max:
  value_float := value.to_float
  in_min_float := in_min.to_float
  in_max_float := in_max.to_float
  out_min_float := out_min.to_float
  out_max_float := out_max.to_float

  // Manejar división por cero si in_min == in_max
  if in_min_float == in_max_float: return out_min_float

  return (value_float - in_min_float) * (out_max_float - out_min_float) / (in_max_float - in_min_float) + out_min_float