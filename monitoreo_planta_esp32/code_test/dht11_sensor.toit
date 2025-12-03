import dhtxx
import gpio

GPIO-PIN-NUM ::=  32

main:
  pin := gpio.Pin GPIO-PIN-NUM
  driver := dhtxx.Dht11 pin

  (Duration --ms=2000).periodic:
    print driver.read
    print driver.read.temperature
    print driver.read.humidity