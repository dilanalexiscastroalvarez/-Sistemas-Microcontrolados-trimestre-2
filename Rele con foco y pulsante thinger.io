#include <ThingerESP32.h>

// Configuración de Thinger.io
#define USER_ID             "dilancas2008"
#define DEVICE_ID           "esp32_dilan"
#define DEVICE_CREDENTIAL   "1234567890"

// Configuración de Red WiFi
#define SSID                "HALLO_Jorge_Castro"
#define SSID_PASSWORD       "Mis3amores81."

const int pinRele = 2;    
const int pinBoton = 4;   

// VARIABLES DE ESTADO
bool permisoThinger = false; // El interruptor maestro de la App
bool estadoFisico = false;   // El estado que cambia con el pulsador
int ultimoEstadoBoton = HIGH;
unsigned long ultimoTiempoDebounce = 0;
unsigned long tiempoDebounce = 50;

ThingerESP32 node(USER_ID, DEVICE_ID, DEVICE_CREDENTIAL);

void setup() {
  Serial.begin(115200);
  pinMode(pinRele, OUTPUT);
  pinMode(pinBoton, INPUT_PULLUP);
  node.add_wifi(SSID, SSID_PASSWORD);

  // RECURSO THINGER: Este es el "Interruptor Maestro"
  node["foco"] << [](pson & in) {
    if (in.is_empty()) {
      in = permisoThinger;
    } else {
      permisoThinger = in;
      
      // Si Thinger apaga el permiso, apagamos el foco inmediatamente
      if (!permisoThinger) {
        estadoFisico = false; 
        digitalWrite(pinRele, LOW);
        Serial.println("SISTEMA BLOQUEADO: Foco apagado por Thinger.");
      } else {
        Serial.println("SISTEMA HABILITADO: El pulsador ahora funciona.");
      }
    }
  };
}

void loop() {
  node.handle();
  
  // Si Thinger está apagado, no leemos el pulsador y salimos del loop
  if (!permisoThinger) {
    return; 
  }

  // Lógica del pulsador (Solo se ejecuta si permisoThinger es true)
  int lectura = digitalRead(pinBoton);

  if (lectura != ultimoEstadoBoton) {
    ultimoTiempoDebounce = millis();
  }

  if ((millis() - ultimoTiempoDebounce) > tiempoDebounce) {
    if (lectura == LOW) {
      estadoFisico = !estadoFisico; // Cambia el estado
      digitalWrite(pinRele, estadoFisico ? HIGH : LOW);
      
      Serial.print("Pulsador usado. Foco: ");
      Serial.println(estadoFisico ? "ON" : "OFF");
      
      // Esperar a que suelte el botón
      while(digitalRead(pinBoton) == LOW) { delay(10); }
    }
  }
  
  ultimoEstadoBoton = lectura;
}
