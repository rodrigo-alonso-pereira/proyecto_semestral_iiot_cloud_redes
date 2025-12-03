import gpio
import hc-sr04

TRIGGER ::= 33
ECHO ::= 32

main:
  trigger := gpio.Pin TRIGGER
  echo := gpio.Pin ECHO
  sensor := hc-sr04.Driver --echo=echo --trigger=trigger

  while true:
    distance := sensor.read-distance
    print "measured $distance mm"
    sleep --ms=500
