import gpio

main:
  leds := [
    gpio.Pin 32 --output,
    gpio.Pin 33 --output,
    gpio.Pin 25 --output,
    gpio.Pin 26 --output,
  ]

  while true:
  // Turn each LED on for 500ms.
    leds.do:
      it.set 1
      sleep --ms=1000
      it.set 0

  // Shut down each pin.
  leds.do: it.close
