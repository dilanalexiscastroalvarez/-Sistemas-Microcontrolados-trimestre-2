#include <ThingerESP32.h>

// Configuración de Thinger.io
#define USER_ID             "dilancas2008"
#define DEVICE_ID           "esp32_dilan"
#define DEVICE_CREDENTIAL   "1234567890"

// Configuración WiFi
#define SSID                "MECATRONICA_3ABC"
#define SSID_PASSWORD       "MEC2025@."

// Pines del Sensor HC-SR04
const int trigPin = 5;
const int echoPin = 18;

ThingerESP32 thing(USER_ID, DEVICE_ID, DEVICE_CREDENTIAL);

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  Serial.begin(115200);
  
  thing.add_wifi(SSID, SSID_PASSWORD);

  // Recurso de Thinger.io optimizado
  thing["distancia"] >> [](pson& out){
    float valor = leerDistancia();
    // Forzamos el redondeo a 2 decimales antes de enviar
    out = (float)((int)(valor * 100 + 0.5)) / 100.0;
  };
}

float leerDistancia() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  long duration = pulseIn(echoPin, HIGH);
  
  // Cálculo de distancia
  float distanceCm = duration * 0.0343 / 2.0;

  // Límite máximo de 30 cm
  if (distanceCm > 30.0) {
    distanceCm = 30.00;
  }

  return distanceCm;
}

void loop() {
  thing.handle();
}
