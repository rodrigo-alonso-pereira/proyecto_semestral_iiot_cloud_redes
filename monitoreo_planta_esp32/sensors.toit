import math
import gpio // Toit GPIO library
import gpio.adc // Toit ADC library
import dhtxx // Toit DHTxx sensor library


// Definición de la interfaz común para todos los sensores.
interface Sensor:
  read -> num

// Implementación de un sensor de humedad del suelo usando ADC.
class MoistureSensor implements Sensor:
  pin_ /gpio.Pin
  adc_ /adc.Adc

  constructor .pin_:
      this.pin_ = pin_ // Inicializar el pin
      this.adc_ = adc.Adc pin_ // Inicializar ADC en el pin dado
  
  read -> float:
    valor_bruto := adc_.get //Valor medido por el sensor
    return valor_bruto.to_float // Retornar el valor como float

// Implementación DTH11 sensor de temperatura y humedad ambiental.
class TempAndHumSensor implements Sensor:
  pin_ /gpio.Pin
  driver_ /dhtxx.Dht11

  constructor .pin_:
      this.pin_ = pin_ // Inicializar el pin
      this.driver_ = dhtxx.Dht11 pin_ // Inicializar DHT11 en el pin dado
  
  read -> float:
    temperatura := driver_.read.temperature
    return temperatura.to_float // Retornar la temperatura como float
  
  read_humidity -> float:
    humedad := driver_.read.humidity
    return humedad.to_float // Retornar la humedad como float

// Implementacion sensor de luz
class LightSensor implements Sensor:
    pin_ /gpio.Pin
    adc_ /adc.Adc
    
    constructor .pin_:
        this.pin_ = pin_ // Inicializar el pin
        this.adc_ = adc.Adc pin_ // Inicializar ADC en el pin dado
    
    read -> float:
        valor_bruto := adc_.get //Valor medido por el sensor
        return valor_bruto.to_float // Retornar el valor como float

// Clase para muestrear un sensor en ráfaga.
class BurstSampler:
  sensor_ /Sensor

  constructor .sensor_: // Constructor privado que recibe un sensor.
    this.sensor_ = sensor_

  // Método para tomar múltiples muestras con un retardo opcional entre ellas.
  // reader es un block que define cómo leer del sensor.
  sample --count/int=10 --delay_ms/int=25 [reader] -> List:
    samples := [] // Lista dinámica vacía.
    
    count.repeat: // Muestrear 'count' veces.
      val := reader.call sensor_ // Llamar al block pasando el sensor
      samples.add val
      if delay_ms > 0:
        sleep --ms=delay_ms
        
    return samples