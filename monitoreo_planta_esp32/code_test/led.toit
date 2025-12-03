import gpio

main:
  pin := gpio.Pin 32 --output
  // SOS signal
  while true:
    for i := 0; i < 3; i += 1:
      pin.set 0
      sleep --ms=500
      pin.set 1
      sleep --ms=100
    
    for i := 0; i < 3; i += 1:
      pin.set 0
      sleep --ms=500
      pin.set 1
      sleep --ms=1000
    
    for i := 0; i < 3; i += 1:
      pin.set 0
      sleep --ms=500
      pin.set 1
      sleep --ms=100
    
    pin.set 0
    sleep --ms=2000

        

    
