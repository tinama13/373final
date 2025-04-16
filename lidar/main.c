/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "stdbool.h"
#include "math.h"
#include "stdio.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define PI 3.141592654
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
UART_HandleTypeDef hlpuart1;
UART_HandleTypeDef huart2;
UART_HandleTypeDef huart3;

/* USER CODE BEGIN PV */
uint8_t data_buffer[2000];

char uart_rx_buffer[64];

float theta_min = 0, theta_max = 90;
float x_min = 9, x_max = 46;
float y_min = 0, y_max = 31;

float x_hundreds = 5;
float x_tens_ones = 65;
float y_hundreds = 4;
float y_tens_ones = 58;

int x_resolution = 565;
int y_resolution = 458;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_USART3_UART_Init(void);
static void MX_LPUART1_UART_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

void reset_lidar(){
	uint8_t message[2] = {'\0'};
	uint8_t garbage[64] = {'\0'};

	message[0] = 0xA5;
	message[1] = 0x40;
	//printf("\nReset start\n");

	HAL_StatusTypeDef ret;

	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
	ret = HAL_UART_Receive(&huart2, garbage, 64, 1000);
	HAL_Delay(50);
	//printf("\nReset done\n");
}

//void check_info_and_health(){
//	uint8_t message[260] = {'\0'};
//	uint8_t descriptor_buffer[7] = {'\0'};
//	uint8_t data_buffer[1000] = {'\0'};
//
//
//	message[0] = 0xA5;
//	message[1] = 0x50;	//GET_INFO
////	printf("\nchecking device info...\n");
//	HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, data_buffer, 20, HAL_MAX_DELAY);
//	HAL_Delay(5);
//
////	printf("GET_INFO: Descriptor\n");
////	printf("\texpected \t: 0xa5 0x5a 0x14 0x4\n");
////	printf("\tgot \t\t: %#x %#x %#x %#x\n", descriptor_buffer[0], descriptor_buffer[1], descriptor_buffer[2], descriptor_buffer[6]);
////	printf("GET_INFO: Data Buffer\n");
//	int A = data_buffer[0]/16;
//	int M = data_buffer[0]%16;
////	printf("\tModel \t\t: A%d M%d\n", A,M);
//
//
//	message[0] = 0xA5;
//	message[1] = 0x52;	//GET_HEALTH
////	printf("\nchecking lidar health...\n");
//	HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, data_buffer, 3, HAL_MAX_DELAY);
//	HAL_Delay(5);
//
//	printf("GET_HEALTH: Descriptor\n");
//	printf("\texpected \t: 0xa5 0x5a 0x3 0x6\n");
//	printf("\tgot \t\t: %#x %#x %#x %#x\n", descriptor_buffer[0], descriptor_buffer[1], descriptor_buffer[2], descriptor_buffer[6]);
//	printf("GET_HEALTH: Data Buffer\n");
//	printf("\tNote: 0 = Good\t1 = Warning\t2 = Error\n");
//	int error_code = (data_buffer[2]<<8)|data_buffer[1];
//	printf("\tstatus: %d \t error_code: %d\n", data_buffer[0], error_code);
//}
//
//void check_sample_rate(){
//	uint8_t message[260] = {'\0'};
//	uint8_t descriptor_buffer [7] = {'\0'};
//	uint8_t data_buffer[1000] = {'\0'};
//
//	message[0] = 0xA5;
//	message[1] = 0x59;
//	printf("\nchecking sample rate...\n");
//	HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, data_buffer, 4, HAL_MAX_DELAY);
//	HAL_Delay(5);
//
//	printf("GET_SAMPLE_RATE: Descriptor\n");
//	printf("\texpected \t: 0xa5 0x5a 0x4 0x15\n");
//	printf("\tgot \t\t: %#x %#x %#x %#x\n", descriptor_buffer[0], descriptor_buffer[1], descriptor_buffer[2], descriptor_buffer[6]);
//	printf("GET_SAMPLE_RATE: Data Buffer\n");
//	int t_standard = (data_buffer[1]<<8)|(data_buffer[0]);
//	int t_express = (data_buffer[3]<<8)|(data_buffer[2]);
//	printf("\tstandard: %duSec\texpress: %duSec\n", t_standard, t_express);
//}
//
//void check_force_scan(){
//	uint8_t message[260] = {'\0'};
//	uint8_t descriptor_buffer [7] = {'\0'};
//	uint8_t data_buffer[2000] = {'\0'};
//
//	int num_data = 300;
//
//	message[0] = 0xA5;
//	message[1] = 0x21;
//	printf("\nchecking force scan...\n");
//	HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//	HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	HAL_Delay(700);
//	HAL_UART_Receive(&huart2, data_buffer, 5*num_data, HAL_MAX_DELAY);
//	HAL_Delay(0.5*num_data);
//	message[0] = 0xA5;
//	message[1] = 0x25;
//	HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//
//	printf("FORCE_SCAN: Descriptor\n");
//	printf("\texpected \t: 0xa5 0x5a 0x5 0x40 0x81\n");
//	printf("\tgot \t\t: %#x %#x %#x %#x %#x\n", descriptor_buffer[0], descriptor_buffer[1], descriptor_buffer[2], descriptor_buffer[5], descriptor_buffer[6]);
//	printf("FORCE_SCAN: Data Buffer\n");
//
//	for(int i = 0; i < num_data; i++){
//		int Angle = (data_buffer[(5*i)+2]<<7)|(data_buffer[(5*i)+1]>>1);
//		float angle = (float)(Angle) / 64.0;
//		int Distance = (data_buffer[(5*i)+4]<<8)|(data_buffer[(5*i)+3]);
//		float distance = (float)(Distance) / 4.0;
//
//		printf("angle: %f\tdistance: %f\n", angle, distance);
//	}
//
//	printf("end");
//}

bool theta_in_range(float theta_check, float error, float theta_lo, float theta_hi){
	if(theta_check >= theta_lo && theta_check < theta_hi)
		return true;
	theta_check += error;
	if((theta_check >= theta_lo && theta_check < theta_hi)||(theta_check-360.0 >= theta_lo && theta_check-360.0 < theta_hi))
		return true;
	theta_check -= 2.0*error;
	if((theta_check >= theta_lo && theta_check < theta_hi)||(theta_check+360.0 >= theta_lo && theta_check+360.0 < theta_hi))
		return true;

	return false;
}

float get_x(float r, float theta){
	return r*cos(theta*PI/180.0);
}

float get_y(float r, float theta){
	return r*sin(theta*PI/180.0);
}


bool xy_in_range(float r, float theta, float max_x, float max_y){
	float cur_x = get_x(r, theta);
	float cur_y = get_y(r, theta);

//	printf("r=%f\ttheta=%f\nx=%f\ty=%f\n", r, theta, cur_x, cur_y);

	return (cur_x <= max_x && cur_y <= max_y);
}

//void check_angle_scan(float theta_lo, float theta_hi, float d_lo, float d_hi){
//	uint8_t message[2] = {'\0'};
//	uint8_t descriptor_buffer [7] = {'\0'};
//
//	int num_data = 280;
//
//	message[0] = 0xA5;
//	message[1] = 0x20;
//
//	HAL_StatusTypeDef ret;
//
////	printf("\nchecking normal scan...\n");
//	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//	ret = HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	ret = HAL_UART_Receive(&huart2, data_buffer, 5*num_data, HAL_MAX_DELAY);
//
////	HAL_Delay(1500);
//
//
////	HAL_Delay(0.5*num_data);
//	message[0] = 0xA5;
//	message[1] = 0x25;
//	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//
//	while (ret == HAL_OK)
//	{
//		ret = HAL_UART_Receive(&huart2, descriptor_buffer, 1, 1000);
//	}
////	printf("ANGLE_SCAN: Descriptor\n");
////	printf("\texpected \t: 0xa5 0x5a 0x5 0x40 0x81\n");
////	printf("\tgot \t\t: %#x %#x %#x %#x %#x\n", descriptor_buffer[0], descriptor_buffer[1], descriptor_buffer[2], descriptor_buffer[5], descriptor_buffer[6]);
//	HAL_UART_Receive(&huart2, data_buffer, 10, 100);
//	HAL_Delay(2);
//
//
////	printf("Scanning for angle from %f deg to %f deg\n", theta_lo, theta_hi);
////	printf("max dist for X (%f deg): %f cm\tmax dist for Y (%f deg): %f cm\n", theta_lo, d_lo/10, theta_hi, d_hi/10);
//
//	float xx = 0;
//	float yy = 0;
//	int k = 0;
//
//	for(int i = 0; i < num_data; i++){
//		int Angle = (data_buffer[(5*i)+2]<<7)|(data_buffer[(5*i)+1]>>1);
//		float angle = (float)(Angle) / 64.0;
//		int Distance = (data_buffer[(5*i)+4]<<8)|(data_buffer[(5*i)+3]);
//		float distance = (float)(Distance) / 4.0;
//
//		if(distance <= 1.0) continue;
//
//		float cur_x = get_x(distance, angle)/10;
//		float cur_y = get_y(distance, angle)/10;
//
//		if(theta_in_range(angle, 10.0, theta_lo, theta_hi) && xy_in_range(distance, angle, d_lo, d_hi)){
//			printf("(x,y): (%f, %f)cm\n", cur_x, cur_y);
//			k++;
//			xx = xx+cur_x;
//			yy = yy+cur_y;
//		}
//
//	}
//	float avg_x = xx/((int)k);
//	float avg_y = yy/((int)k);
//
//	printf("Avg of %d points (x,y): (%f, %f)cm\n", k, avg_x, avg_y);
//
//}

//
//void express_scan(){
//	uint8_t message[9] = {'\0'};
//	uint8_t descriptor_buffer[7] = {'\0'};
//
//
//	message[0] = 0xA5;
//	message[1] = 0x82;
//	message[2] = 0x05;
//	message[8] = 0x22;
//
//	HAL_StatusTypeDef ret;
//
////	printf("\nchecking normal scan...\n");
//	ret = HAL_UART_Transmit(&huart2, message, 9, HAL_MAX_DELAY);
//	ret = HAL_UART_Receive(&huart2, descriptor_buffer, 7, HAL_MAX_DELAY);
//	ret = HAL_UART_Receive(&huart2, data_buffer, 84, HAL_MAX_DELAY);
//
////	HAL_Delay(1500);
//
//
////	HAL_Delay(0.5*num_data);
//	message[0] = 0xA5;
//	message[1] = 0x25;
//	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
//
//	while (ret == HAL_OK)
//	{
//		ret = HAL_UART_Receive(&huart2, descriptor_buffer, 1, 1000);
//	}
//	HAL_UART_Receive(&huart2, data_buffer, 10, 100);
//	HAL_Delay(2);
//
//}

void scan_xy(float theta_lo, float theta_hi, float x_lo, float x_hi, float y_lo, float y_hi){
	uint8_t message[2] = {'\0'};
	uint8_t descriptor_buffer [7] = {'\0'};

	int num_data = 280;

	message[0] = 0xA5;
	message[1] = 0x20;

	HAL_StatusTypeDef ret;

	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);
	ret = HAL_UART_Receive(&huart2, descriptor_buffer, 7, 500);
	ret = HAL_UART_Receive(&huart2, data_buffer, 5*num_data, 1700);

	message[0] = 0xA5;
	message[1] = 0x25;
	ret = HAL_UART_Transmit(&huart2, message, 2, HAL_MAX_DELAY);

	while (ret == HAL_OK){ret = HAL_UART_Receive(&huart2, descriptor_buffer, 1, 1000);}

	HAL_UART_Receive(&huart2, data_buffer, 10, 100);
	HAL_Delay(2);

	float xx = 0;
	float yy = 0;
	int k = 0;

	for(int i = 0; i < num_data; i++){
		int Angle = (data_buffer[(5*i)+2]<<7)|(data_buffer[(5*i)+1]>>1);
		float angle = (float)(Angle) / 64.0;
		int Distance = (data_buffer[(5*i)+4]<<8)|(data_buffer[(5*i)+3]);
		float distance = (float)(Distance) / 4.0;

		if(distance <= 1.0) continue;

		float cur_x = get_x(distance, angle)/10;
		float cur_y = get_y(distance, angle)/10;

		if(theta_in_range(angle, 10.0, theta_lo, theta_hi) && cur_x >= x_lo && cur_x <= x_hi && cur_y >= y_lo && cur_y <= y_hi){
			k++;
			xx = xx+cur_x;
			yy = yy+cur_y;
		}

	}
	float avg_x = xx/((int)k);
	float avg_y = yy/((int)k);

	uint16_t x_coor = x_resolution*((avg_x - x_lo) / (x_hi - x_lo));
	uint16_t y_coor = y_resolution*((avg_y - y_lo) / (y_hi - y_lo));

	uint8_t x_upper = (x_coor >> 8)& 0xFF;
	uint8_t x_lower = (x_coor & 0xFF);
	uint8_t y_upper = (y_coor >> 8)& 0xFF;
	uint8_t y_lower = (y_coor & 0xFF);

	uint8_t xy_coor[4] = {x_upper, x_lower, y_upper, y_lower};

	ret = HAL_UART_Transmit(&huart3, xy_coor, 4, HAL_MAX_DELAY);

	printf("Avg of %d points (x,y): (%f, %f)cm\n\tcoordinate: (%d, %d)\n", k, avg_x, avg_y, x_coor, y_coor);
}

void ask_calibration_input(const char* label, float* variable) {
	char c;
	int i = 0;
    bool reading = true;

	printf("Enter %s: ", label);
	fflush(stdout);

	memset(uart_rx_buffer, 0, sizeof(uart_rx_buffer));

	while (reading && i < sizeof(uart_rx_buffer) - 1) {
		if (HAL_UART_Receive(&hlpuart1, (uint8_t*)&c, 1, 5000) == HAL_OK) {
			HAL_UART_Transmit(&hlpuart1, (uint8_t*)&c, 1, 100);

			if (c == '\r' || c == '\n') {
				reading = false;
				HAL_UART_Receive(&hlpuart1, (uint8_t*)&c, 1, 10);
				break;
			}

			uart_rx_buffer[i++] = c;
		} else {
			break;
		}
	}

	uart_rx_buffer[i] = '\0';

	if (sscanf(uart_rx_buffer, "%f", variable) == 1) {
		printf("\n%s set to: %f\n", label, *variable);
	} else {
		printf("\nInvalid input for %s. Using default: %f\n", label, *variable);
	}

	fflush(stdout);
}


/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART2_UART_Init();
  MX_USART3_UART_Init();
  MX_LPUART1_UART_Init();
  /* USER CODE BEGIN 2 */

  printf("---\nNew Run\n");
  HAL_Delay(100);
  reset_lidar();
  printf("---\nReset Done\n");

  printf("Would you like to customize lidar parameters? (Y=1 / N=0)\n");
  float customize_param = 0;
  ask_calibration_input("(Y=1 / N=0)", &customize_param);

  if(customize_param == 1){
	  ask_calibration_input("x_hundreds", &x_hundreds);
	  ask_calibration_input("x_tens_ones", &x_tens_ones);
	  ask_calibration_input("y_hundreds", &y_hundreds);
	  ask_calibration_input("y_tens_ones", &y_tens_ones);
	  x_resolution = (100*(int)(x_hundreds))+((int)(x_tens_ones));
	  y_resolution = (100*(int)(y_hundreds))+((int)(y_tens_ones));
	  ask_calibration_input("theta_min", &theta_min);
	  ask_calibration_input("theta_max", &theta_max);
	  ask_calibration_input("x_min", &x_min);
	  ask_calibration_input("x_max", &x_max);
	  ask_calibration_input("y_min", &y_min);
	  ask_calibration_input("y_max", &y_max);
  }

//  printf("x_hud = %d, x_tenone = %d\n", x_hundreds, x_tens_ones);

  printf("Starting scan with parameters:\n");
  printf("resolution: (%d,%d), theta: [%f, %f], x: [%f, %f], y: [%f, %f]\n", x_resolution, y_resolution, theta_min, theta_max, x_min, x_max, y_min, y_max);

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
	  scan_xy(theta_min, theta_max, x_min, x_max, y_min, y_max);

	  /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  if (HAL_PWREx_ControlVoltageScaling(PWR_REGULATOR_VOLTAGE_SCALE1) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_MSI;
  RCC_OscInitStruct.MSIState = RCC_MSI_ON;
  RCC_OscInitStruct.MSICalibrationValue = 0;
  RCC_OscInitStruct.MSIClockRange = RCC_MSIRANGE_6;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_MSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief LPUART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_LPUART1_UART_Init(void)
{

  /* USER CODE BEGIN LPUART1_Init 0 */

  /* USER CODE END LPUART1_Init 0 */

  /* USER CODE BEGIN LPUART1_Init 1 */

  /* USER CODE END LPUART1_Init 1 */
  hlpuart1.Instance = LPUART1;
  hlpuart1.Init.BaudRate = 115200;
  hlpuart1.Init.WordLength = UART_WORDLENGTH_8B;
  hlpuart1.Init.StopBits = UART_STOPBITS_1;
  hlpuart1.Init.Parity = UART_PARITY_NONE;
  hlpuart1.Init.Mode = UART_MODE_TX_RX;
  hlpuart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  hlpuart1.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  hlpuart1.Init.ClockPrescaler = UART_PRESCALER_DIV1;
  hlpuart1.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  hlpuart1.FifoMode = UART_FIFOMODE_DISABLE;
  if (HAL_UART_Init(&hlpuart1) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetTxFifoThreshold(&hlpuart1, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetRxFifoThreshold(&hlpuart1, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_DisableFifoMode(&hlpuart1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN LPUART1_Init 2 */

  /* USER CODE END LPUART1_Init 2 */

}

/**
  * @brief USART2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART2_UART_Init(void)
{

  /* USER CODE BEGIN USART2_Init 0 */

  /* USER CODE END USART2_Init 0 */

  /* USER CODE BEGIN USART2_Init 1 */

  /* USER CODE END USART2_Init 1 */
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  huart2.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart2.Init.ClockPrescaler = UART_PRESCALER_DIV1;
  huart2.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart2) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetTxFifoThreshold(&huart2, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetRxFifoThreshold(&huart2, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_DisableFifoMode(&huart2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART2_Init 2 */

  /* USER CODE END USART2_Init 2 */

}

/**
  * @brief USART3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART3_UART_Init(void)
{

  /* USER CODE BEGIN USART3_Init 0 */

  /* USER CODE END USART3_Init 0 */

  /* USER CODE BEGIN USART3_Init 1 */

  /* USER CODE END USART3_Init 1 */
  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  huart3.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart3.Init.ClockPrescaler = UART_PRESCALER_DIV1;
  huart3.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetTxFifoThreshold(&huart3, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetRxFifoThreshold(&huart3, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_DisableFifoMode(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART3_Init 2 */

  /* USER CODE END USART3_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOE_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOF_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOG_CLK_ENABLE();
  HAL_PWREx_EnableVddIO2();

  /*Configure GPIO pins : PE2 PE3 */
  GPIO_InitStruct.Pin = GPIO_PIN_2|GPIO_PIN_3;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF13_SAI1;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pins : PF0 PF1 PF2 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF4_I2C2;
  HAL_GPIO_Init(GPIOF, &GPIO_InitStruct);

  /*Configure GPIO pin : PF7 */
  GPIO_InitStruct.Pin = GPIO_PIN_7;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF13_SAI1;
  HAL_GPIO_Init(GPIOF, &GPIO_InitStruct);

  /*Configure GPIO pins : PC0 PC1 PC2 PC3 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3;
  GPIO_InitStruct.Mode = GPIO_MODE_ANALOG_ADC_CONTROL;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : PA0 */
  GPIO_InitStruct.Pin = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF1_TIM2;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PA1 PA3 */
  GPIO_InitStruct.Pin = GPIO_PIN_1|GPIO_PIN_3;
  GPIO_InitStruct.Mode = GPIO_MODE_ANALOG_ADC_CONTROL;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PA4 PA5 PA6 PA7 */
  GPIO_InitStruct.Pin = GPIO_PIN_4|GPIO_PIN_5|GPIO_PIN_6|GPIO_PIN_7;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI1;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : PB0 */
  GPIO_InitStruct.Pin = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF2_TIM3;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : PB1 */
  GPIO_InitStruct.Pin = GPIO_PIN_1;
  GPIO_InitStruct.Mode = GPIO_MODE_ANALOG_ADC_CONTROL;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PB2 PB6 */
  GPIO_InitStruct.Pin = GPIO_PIN_2|GPIO_PIN_6;
  GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PE7 PE8 PE9 PE10
                           PE11 PE12 PE13 */
  GPIO_InitStruct.Pin = GPIO_PIN_7|GPIO_PIN_8|GPIO_PIN_9|GPIO_PIN_10
                          |GPIO_PIN_11|GPIO_PIN_12|GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF1_TIM1;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pins : PE14 PE15 */
  GPIO_InitStruct.Pin = GPIO_PIN_14|GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF3_TIM1_COMP1;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pin : PB10 */
  GPIO_InitStruct.Pin = GPIO_PIN_10;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF1_TIM2;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PB12 PB13 PB15 */
  GPIO_InitStruct.Pin = GPIO_PIN_12|GPIO_PIN_13|GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF13_SAI2;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : PB14 */
  GPIO_InitStruct.Pin = GPIO_PIN_14;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF14_TIM15;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PD14 PD15 */
  GPIO_InitStruct.Pin = GPIO_PIN_14|GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF2_TIM4;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

  /*Configure GPIO pin : PC6 */
  GPIO_InitStruct.Pin = GPIO_PIN_6;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF13_SAI2;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : PC7 */
  GPIO_InitStruct.Pin = GPIO_PIN_7;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF2_TIM3;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : PC8 PC9 PC12 */
  GPIO_InitStruct.Pin = GPIO_PIN_8|GPIO_PIN_9|GPIO_PIN_12;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF12_SDMMC1;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : PA8 PA10 */
  GPIO_InitStruct.Pin = GPIO_PIN_8|GPIO_PIN_10;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF10_OTG_FS;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : PA9 */
  GPIO_InitStruct.Pin = GPIO_PIN_9;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PC10 PC11 */
  GPIO_InitStruct.Pin = GPIO_PIN_10|GPIO_PIN_11;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF8_UART4;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : PD0 */
  GPIO_InitStruct.Pin = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF9_CAN1;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

  /*Configure GPIO pin : PD2 */
  GPIO_InitStruct.Pin = GPIO_PIN_2;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF12_SDMMC1;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

  /*Configure GPIO pins : PB3 PB4 PB5 */
  GPIO_InitStruct.Pin = GPIO_PIN_3|GPIO_PIN_4|GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF6_SPI3;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PB8 PB9 */
  GPIO_InitStruct.Pin = GPIO_PIN_8|GPIO_PIN_9;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : PE0 */
  GPIO_InitStruct.Pin = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF2_TIM4;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

#ifdef __GNUC__
#define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */
PUTCHAR_PROTOTYPE
{
  HAL_UART_Transmit(&hlpuart1, (uint8_t *)&ch, 1, 0xFFFF);
  return ch;
}


/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
