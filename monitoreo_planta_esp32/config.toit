// --- Constantes de Configuración ---
PIN_SENSOR_MOISTURE ::= 34 // Pin para sensor M-SENS-V1.2
PIN_SENSOR_DHT11 ::=  32 // Pin para sensor DHT11
PIN_SENSOR_LIGHT ::= 35 // Pin para sensor TEMT6000 
MQTT_CLIENT_ID ::= "esp32_01" // ID del cliente MQTT
MQTT_HOST ::= "mqtt.fabricainteligente.cl" // Broker público de MQTT
MQTT_TOPIC ::= "usach/redes/data" // Topico MQTT productivo
// MQTT_TOPIC ::= "usach_redes/test" // Topico MQTT para publicar datos sin guardar en bd
MQTT_USERNAME ::= "usach_redes" // Nombre de usuario MQTT
MQTT_PASSWORD ::= "usachredes" // Contraseña MQTT
LONGITUD_DEVICE ::= -70.65771655814775 // Longitud de la ubicación del dispositivo
LATITUD_DEVICE ::= -33.52389127662384  // Latitud de la ubicación del dispositivo

// Datos de calibracion 
VALOR_AIRE ::= 2.2269999999999998685 // Alto valor ADC (seco) -> Mapea a 0%
VALOR_AGUA ::= 0.89000000000000001332 // Bajo valor ADC (húmedo) -> Mapea a 100%
VALOR_LUZ ::= 3.1450000000000000178 

// Configuración de Adquisición
BURST_COUNT    ::= 100   // Cantidad de muestras para estadística
BURST_DELAY_MS ::= 25   // Tiempo entre muestras (ms)
FREQUENCY_MS  ::= 60000 // 1 minuto de intervalo entre envíos de datos (ms)

// Canales a escanear
SCAN_CHANNELS ::= #[1, 4, 5, 6, 7, 2, 8, 9, 10, 11, 3]