/*

STM32's output format
void send_motion_packet(...) {
  uint8_t packet[7];
  packet[0] = 0xAA;
  packet[1] = motion_state; // 1 is idle, 2 is tap
  packet[2] = lidar_x_upper;
  packet[3] = lidar_x_lower;
  packet[4] = lidar_y_upper;
  packet[5] = lidar_y_lower;
  packet[6] = 0x00;

  HAL_UART_Transmit(&huart2, packet, 7, HAL_MAX_DELAY);
}

*/
#include <BleMouse.h>

#define RXD2 16
#define TXD2 17

BleMouse bleMouse;
HardwareSerial uartSerial(2);

#define PACKET_SIZE 7

void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE work!");
  bleMouse.begin();

  uartSerial.begin(9600, SERIAL_8N1, RXD2, TXD2);
}

void loop() {
  // Only process if the BLE Mouse is connected
  if (bleMouse.isConnected()) {
    // Wait until a full packet (7 bytes) is received
    if (uartSerial.available() >= PACKET_SIZE) {
      uint8_t packet[PACKET_SIZE];
      
      for (int i = 0; i < PACKET_SIZE; i++) {
        packet[i] = uartSerial.read();
      }
      
      // Check the header and footer bytes for validity
      if (packet[0] != 0xAA) {
        Serial.println("Invalid packet header.");
        return;
      }
      if (packet[6] != 0x00) {
        Serial.println("Invalid packet footer.");
        return;
      }
      
      // Parse the packet:
      // packet[1]: motion_state (1 is idle, 2 is tap)
      // packet[2] and packet[3]: lidar_x (upper then lower byte)
      // packet[4] and packet[5]: lidar_y (upper then lower byte)
      uint8_t motion_state = packet[1];
      int16_t lidar_x = ((int16_t)packet[2] << 8) | packet[3];
      int16_t lidar_y = ((int16_t)packet[4] << 8) | packet[5];
      
      // Debug prints
      Serial.print("Motion state: ");
      Serial.println(motion_state);
      Serial.print("Lidar X: ");
      Serial.println(lidar_x);
      Serial.print("Lidar Y: ");
      Serial.println(lidar_y);
      
      // Move the mouse pointer using the lidar values
      bleMouse.move(lidar_x, lidar_y);
      
      // If motion_state equals 2 (tap), trigger a left click.
      if (motion_state == 2) {
        bleMouse.click(MOUSE_LEFT);
        Serial.println("Mouse click triggered (tap detected).");
      }
    }
  } else {
    Serial.println("BLE Mouse not connected, waiting...");
  }
  
  delay(10);
}
