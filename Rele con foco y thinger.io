#include <WiFi.h>
#include <ThingerESP32.h>

// 1. Credenciales de Thinger.io (Obtenlas en tu consola)
#define USER_ID             "dilancas2008"
#define DEVICE_ID           "esp32_dilan"
#define DEVICE_CREDENTIAL   "1234567890"

// 2. Configuración de Red
#define SSID                "HALLO_Jorge_Castro"
#define SSID_PASSWORD       "Mis3amores81."

ThingerESP32 thing(USER_ID, DEVICE_ID, DEVICE_CREDENTIAL);

const int relay = 2;

void setup() {
  Serial.begin(115200);
  
  pinMode(relay, OUTPUT);
  // Iniciamos el relay apagado (HIGH en la mayoría de módulos de relay)
  digitalWrite(relay, HIGH);

  // Conexión WiFi
  thing.add_wifi(SSID, SSID_PASSWORD);

  // 3. RECURSO DE THINGER.IO
  // Este bloque crea un switch en la plataforma para controlar el pin
  thing["relay"] << [](pson & in) {
    if (in.is_empty()) {
      // Esto devuelve el estado actual al dashboard
      in = (digitalRead(relay) == LOW); 
    } else {
      // Esto recibe el estado del switch del dashboard
      // Si el switch está ON, ponemos el pin en LOW (encendido)
      digitalWrite(relay, in ? LOW : HIGH);
    }
  };
}

void loop() {
  thing.handle();
}
