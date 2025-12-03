import mqtt
import encoding.json

CLIENT-ID ::= "lab"  // Use a random client ID.
//HOST ::= "test.mosquitto.org"
//TOPIC ::= "toit-mqtt/tutorial"
HOST ::= "mqtt.fabricainteligente.cl" // Broker público de MQTT
TOPIC ::= "usach_redes/test" // Tema MQTT para publicar datos
USERNAME ::= "usach_redes" // Nombre de usuario MQTT
PASSWORD ::= "usachredes" // Contraseña MQTT

main:
  client := mqtt.Client --host=HOST
  //client.start --client-id=CLIENT-ID
  options := mqtt.SessionOptions
      --client-id=CLIENT-ID
      --username=USERNAME 
      --password=PASSWORD
  client.start --options=options

  payload := json.encode {
    "value": "Hello, MQTT from Toit!"
  }
  client.publish TOPIC payload
  client.close
