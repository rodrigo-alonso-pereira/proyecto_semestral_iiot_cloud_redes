// Módulo de funciones estadísticas puras para procesamiento de series de datos.
import ntp
import esp32 show adjust-real-time-clock

// Clase contenedora para funciones estadísticas.
class SignalProcessor:

  // Metodo estático para calcular el promedio de una lista de números.
  static average list/List -> float:
    if list.size == 0: return 0.0
    
    // El método 'reduce' itera sobre la lista acumulando el resultado.
    sum := list.reduce --initial=0.0: | accumulator element | // Guardar el acumulador y el elemento actual
      accumulator + element // Suma el elemento actual al acumulador
    
    return sum.to_float / list.size.to_float // Retorna el promedio como float

  // Metodo estático para calcular la mediana de una lista de números.
  static median input_list/List -> float:
    if input_list.size == 0: return 0.0 // Si la lista está vacía, retornar 0.0
  
    sorted := input_list.sort // Ordenar la lista sin modificar la original.

    n := sorted.size // Tamaño de la lista.
    mid_index := n / 2 // División entera en Toit para índices.

    if n % 2 == 1: // Caso impar: elemento central.
      return sorted[mid_index].to_float
    else: // Caso par: promedio de los dos elementos centrales.
      val_a := sorted[mid_index - 1]
      val_b := sorted[mid_index]
      return (val_a + val_b).to_float / 2.0

// Función para mapear un valor de un rango a otro.
map_range value in_min in_max out_min out_max -> float:
  value_float := value.to_float // valor sensor actual
  in_min_float := in_min.to_float // valor seco (VALOR_AIRE)
  in_max_float := in_max.to_float // valor húmedo (VALOR_AGUA)
  out_min_float := out_min.to_float // 0.0
  out_max_float := out_max.to_float // 100.0

  // Manejar división por cero si in_min == in_max
  if in_min_float == in_max_float: return out_min_float

  // Fórmula de mapeo lineal (interpolación)
  return (value_float - in_min_float) * (out_max_float - out_min_float) / (in_max_float - in_min_float) + out_min_float

// Funcion para corroborar hora NTP
check_ntp_time now/Time:
    if now < (Time.parse "2025-12-07T01:40:00Z"):
      result ::= ntp.synchronize
      if result:
        adjust-real-time-clock result.adjustment

// Función auxiliar para convertir valores con overflow de 16 bits signed a 32 bits unsigned.
to_unsigned_32 value/int -> int:
  if value < 0: // Si es negativo, fue overflow de 16 bits signed
    return value + 65536  // Convertir a unsigned 32 bits sumando 2^16
  return value