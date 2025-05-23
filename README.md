# Turn any flat surface into a interactive touchscreen!
![Demo](https://github.com/user-attachments/assets/44e1a2db-4f7d-4080-8270-4c2ba0e66b18)

**TV** – *Interactive Drawing: Precise stylus input enables real-time drawing and annotation on a large display.*

**Drywall** – *Smart Wall Interface: Turns any wall into an interactive control panel, ideal for home automation or presentations.*

**Cardboard** – *Projected Game Surface: Combines projection and touch sensing to create a portable, low-cost interactive gaming setup.*

**Monitor** – *Touch Retrofits: Adds tap and drag functionality to standard displays, enhancing accessibility and interaction.*

# Motivation

Touchscreens are everywhere, but they’re expensive to scale and limited to the surfaces they’re built into. We wanted to challenge that. What if any flat surface could become interactive, without needing a special screen? This project was born out of that question. By fusing LiDAR, vibration sensing, and embedded systems, we set out to create a low-cost, flexible solution for turning ordinary surfaces into smart, touch-enabled interfaces. Whether for accessibility, education, or creative expression, the potential applications are wide open, and we’re just scratching the surface!

# Project Description
Our project aims to turn any flat surface into an interactive touchscreen interface using LiDAR and vibration sensors. By mounting LiDAR sensors around a surface, we can detect finger positions in real time and calculate precise (x, y) coordinates. These coordinates are processed by a microcontroller and used to control a connected device, such as a computer or projector. To enhance gesture recognition, we integrate an accelerometer and piezoelectric disk that captures surface vibrations to distinguish between different types of touch events like taps, drags, and clicks.

An FPGA drives a VGA output to visualize a virtual cursor directly onto the surface, providing an intuitive user interface and aiding in debugging. The system communicates with external devices via Bluetooth or USB, enabling applications such as turning a TV or table into a touchscreen, creating interactive gaming boards, or building smart interfaces for public spaces.

This project brings together sensors, embedded systems, signal processing, and real time interface control to enable a flexible, portable, and scalable interactive surface solution.

(EECS 373 Winter 25)

## Assembled Device
<img width="608" alt="Screenshot 2025-04-25 at 1 49 42 PM" src="https://github.com/user-attachments/assets/31b070e7-5b7c-4525-8f31-df010fbd9786" />

## Functional Diagram
![373 Proposal Diagram(1)](https://github.com/user-attachments/assets/0f33d81f-187f-4dc6-8e8c-ac5099cc897b)

## Component Diagram
![373 Proposal Diagram](https://github.com/user-attachments/assets/74f4b602-887b-4aab-8d3c-3eef31b23403)

## Drawing Demo
![Untitled-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/aec91933-1f68-47e6-9dd9-3635e6a1ca32)

## Project Video
[![Demo Video](http://img.youtube.com/vi/3E9mqm8sJ4Q/0.jpg)](https://youtu.be/3E9mqm8sJ4Q)


## Hardware Components
Finger Localization
- NUCLEO-L4R5ZI-P
- RPLiDAR A1M8
  
Gesture Sensing
- NUCLEO-L4R5ZI-P
- LSM303DLHC Accelerometer
- Large Enclosed Piezo Element w/Wires

VGA Visualization
- DE2-115 FPGA board

System Integration
- ESP32
- Xbee PCB antenna
---
## References
### Brief Guide to RPLiDAR A1M8
[Google Docs](https://docs.google.com/document/d/1IeCC1AuceanwxWrNEfNu5hHAYbNNzkttbM0vRZzuzNg/edit?usp=sharing)

### STM32 NUCELO-L4R5ZI User Manual
[link](https://www.st.com/resource/en/user_manual/um2179-stm32-nucleo144-boards-mb1312-stmicroelectronics.pdf)

### DE2-115 FPGA Board User Manual
[link](https://www.terasic.com.tw/attachment/archive/502/DE2_115_User_manual.pdf)
