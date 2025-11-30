// statistics.toit
// Módulo de funciones estadísticas puras para procesamiento de series de datos.

// Clase contenedora para funciones estadísticas.
class SignalProcessor:

  // Metodo estático para calcular el promedio de una lista de números.
  static average list/List -> float:
    if list.size == 0: return 0.0
    
    // El método 'reduce' itera sobre la lista acumulando el resultado.
    sum := list.reduce --initial=0.0: | accumulator element | // Guardar el acumulador y el elemento actual
      accumulator + element // Suma el elemento actual al acumulador
    
    return sum.to_float / list.size.to_float // Retorna el promedio como float

  /**
   * Calcula la mediana de una lista de números.
   * 
   * La mediana es el valor que separa la mitad superior de la mitad inferior
   * de una muestra de datos. Es robusta frente a ruido impulsivo.
   * 
   * @param input_list Lista de entrada.
   * @return El valor mediano como float.
   */
  static median input_list/List -> float:
    if input_list.size == 0: return 0.0

    // CRÍTICO: Toit pasa objetos por referencia. El método 'sort' sin argumentos
    // adicionales puede modificar la lista original si se usara --in-place.
    // Sin embargo, la implementación estándar de 'sort' devuelve una nueva lista
    // ordenada, dejando la original intacta, a menos que se especifique lo contrario.
    // Para garantizar la inmutabilidad explícita y seguridad, confiamos en el
    // comportamiento por defecto que retorna una nueva colección o copiamos explícitamente.
    // Según , list.sort retorna una nueva lista ordenada.
    
    sorted := input_list.sort
    
    n := sorted.size
    mid_index := n / 2 // División entera en Toit para índices.

    if n % 2 == 1:
      // Caso impar: el elemento central es la mediana única.
      return sorted[mid_index].to_float
    else:
      // Caso par: promedio de los dos elementos centrales.
      val_a := sorted[mid_index - 1]
      val_b := sorted[mid_index]
      return (val_a + val_b).to_float / 2.0