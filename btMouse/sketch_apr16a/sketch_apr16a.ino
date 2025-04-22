/* TEST TAP AND MOUSE

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

int xPos = 0;
int yPos = 0;


const int xRes = 565;
const int yRes = 458;


const int dispResX = 960;
const int dispResY = 1280;


void mouseMove(int16_t rawX, int16_t rawY) {
  // 1) scale LiDAR movement into display pixels
  int32_t dx = (int32_t)rawX * dispResX / xRes;
  int32_t dy = (int32_t)rawY * dispResY / yRes;

  // 2) chunk into signed‑char steps
  while (dx != 0 || dy != 0) {
    int8_t stepX = 0, stepY = 0;

    if (dx > 0)        stepX =  dx > 127 ? 127 : dx;
    else if (dx < 0)   stepX =  dx < -128 ? -128 : dx;

    if (dy > 0)        stepY =  dy > 127 ? 127 : dy;
    else if (dy < 0)   stepY =  dy < -128 ? -128 : dy;

    bleMouse.move(stepX, stepY);

    delay(5);

    dx -= stepX;
    dy -= stepY;

    //delay(5);  // optional pacing
  }
}


void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE work!");
  bleMouse.begin();

  uartSerial.begin(9600, SERIAL_8N1, RXD2, TXD2);

  //mouseMove(900, 900);
}

void loop() {
  // Only process if the BLE Mouse is connected
  if (bleMouse.isConnected()) {
    // Wait until a full packet (7 bytes) is received
    // in loop(), inside bleMouse.isConnected()
    while (uartSerial.available()) {
      // peek at the next byte in the FIFO
      if (uartSerial.peek() != 0xAA) {
        uartSerial.read();  // throw it away
        continue;           // try again
      }

      // we’ve seen 0xAA sitting at the head of the buffer
      if (uartSerial.available() < PACKET_SIZE) {
        // not enough bytes yet for a full packet
        break;
      }

      // now read the synchronized packet
      uint8_t packet[PACKET_SIZE];
      uartSerial.readBytes(packet, PACKET_SIZE);

      // sanity‑check footer
      if (packet[6] != 0x00) {
        Serial.println("Bad footer, dropping packet.");
        continue;
      }

      // parse!
      uint8_t motion_state = packet[1];
      int16_t lidar_x = (packet[2] << 8) | packet[3];
      int16_t lidar_y = (packet[4] << 8) | packet[5];

      //Serial.printf("State=%u  X=%d  Y=%d\n", motion_state, lidar_x, lidar_y);
      Serial.print("Packet: ");
      for (int i = 0; i < PACKET_SIZE; i++) {
        Serial.print("0x");
        if (packet[i] < 0x10) Serial.print('0');
        Serial.print(packet[i], HEX);
        Serial.print(' ');
      }
      Serial.println();

      if (lidar_x != 0 || lidar_y != 0) {
        int deltaX = lidar_x - xPos;
        int deltaY = lidar_y - yPos;

        mouseMove(deltaX, deltaY);
        xPos = lidar_x;
        yPos = lidar_y;
      }

      if (motion_state == 2) {
        bleMouse.click();
      }
    }

  } else {
    Serial.println("BLE Mouse disconnected, restarting…");
    
  }


  
}
