/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under BSD 3-Clause license,
  * the "License"; You may not use this file except in compliance with the
  * License. You may obtain a copy of the License at:
  *                        opensource.org/licenses/BSD-3-Clause
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "miniplanificador.h"
#include "timer_monitor.h"
#include "arrebote.h"
#include "dwt.h"
#include "sha3.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define TICKS_SISTEMA			(5)
#define LEN_TASK_LIST			(8)
#define PULSADOR_ACTIVO_BAJO	(1)
#define PULSADOR_TICS			(20)
#define PULSADOR_PUERTO			(GPIOB)
#define PULSADOR_PIN			(GPIO_PIN_0)
#define LED_PLACA_PUERTO		(GPIOC)
#define LED_PLACA_PIN			(GPIO_PIN_13)
#define LED_TICKS				(43)
#define LEN_BUFFER_SERIE		(128)
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
UART_HandleTypeDef huart1;

/* USER CODE BEGIN PV */
	uint32_t conteo_ticks_tds;
	uint32_t enviar_serie;
	uint32_t serie_disponible;
	uint8_t buffer_serie[LEN_BUFFER_SERIE];
	uint8_t* hash;
	TaskStat lista_tareas[LEN_TASK_LIST];
	arrebote pulsador;
	sha3_context c;


/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART1_UART_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
void falla_sistema(void)
{
	/*Si una tarea se pasa de ticks se hace fallar al sistema*/
	/*__disable_irq();
	while (1)
	{
		for (uint32_t i = 0; i < 100000; i++);
		HAL_GPIO_TogglePin(LED_PLACA_PUERTO, LED_PLACA_PIN);
	}*/
}

uint32_t xorshift32(void)
{
	static uint32_t x = 5761455;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return x;
}

void tarea_calculo(void *p)
{
	uint32_t clave;
	chequear_arrebote(&pulsador, HAL_GPIO_ReadPin(PULSADOR_PUERTO, PULSADOR_PIN));
	if(hay_flanco_arrebote(&pulsador) && serie_disponible)
	{
		clave = xorshift32();
		sha3_Init512(&c);
		sha3_Update(&c, &clave, sizeof(clave));
		hash = (uint8_t*)sha3_Finalize(&c);
		enviar_serie = 1;
	}
}

char bin2hex(uint8_t valor, uint32_t nibble)
{
	if(nibble) valor>>=4;
	valor&=0x0F;
	valor+='0';
	if(valor>'9') valor+=7;
	return valor;
}

void tarea_serie(void *p)
{
	int i;
	static uint32_t estado = 0;
	if(enviar_serie && estado==0)
	{
		enviar_serie = 0;
		serie_disponible = 0;
		for(i=0; i<64; i++)
		{
			buffer_serie[i*2+0]=bin2hex(hash[i], 1);
			buffer_serie[i*2+1]=bin2hex(hash[i], 0);
		}
		buffer_serie[64]='\r';
		buffer_serie[65]='\n';
		buffer_serie[66]=0;
		huart1.Instance->DR = buffer_serie[0];
		estado++;
	}
	else if(estado>0 && estado<66)
	{
		if( huart1.Instance->SR&UART_FLAG_TXE)
		{
			huart1.Instance->DR = buffer_serie[estado++];
		}
	}
	else if(estado == 66)
	{
		if(huart1.Instance->SR&UART_FLAG_TXE)
		{
			estado = 0;
			serie_disponible = 1;
		}
	}
}

void tarea_led(void *p)
{
	static uint32_t tics = LED_TICKS;
	if(!--tics)
	{
		tics = LED_TICKS;
		HAL_GPIO_TogglePin(LED_PLACA_PUERTO, LED_PLACA_PIN);
	}
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */
	uint32_t ticks = 0;
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
  MX_USART1_UART_Init();
  /* USER CODE BEGIN 2 */
  inic_timer(1);
  inicializar_despachador(lista_tareas, LEN_TASK_LIST, start_timer, stop_timer, falla_sistema);
  inicializar_arrebote(&pulsador, PULSADOR_ACTIVO_BAJO, PULSADOR_TICS);
  agregar_tarea(lista_tareas, tarea_calculo, NULL, 0, 1, 0, 60000);
  agregar_tarea(lista_tareas, tarea_serie,   NULL, 0, 1, 0, 60000);
  agregar_tarea(lista_tareas, tarea_led,     NULL, 0, 3, 0, 60000);
  enviar_serie = 0;
  serie_disponible = 1;
  conteo_ticks_tds = HAL_GetTick();
  dwt_inic();
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
	  dwt_reset();
	  if((HAL_GetTick()-conteo_ticks_tds)>=TICKS_SISTEMA)
	  {
		  conteo_ticks_tds = HAL_GetTick();
		  despachar_tareas();
	  }
	  if(dwt_read()>ticks)
	  {
		  ticks = dwt_read();
	  }
  }
  UNUSED(ticks);
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

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART1_UART_Init(void)
{

  /* USER CODE BEGIN USART1_Init 0 */

  /* USER CODE END USART1_Init 0 */

  /* USER CODE BEGIN USART1_Init 1 */

  /* USER CODE END USART1_Init 1 */
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 4800;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART1_Init 2 */

  /* USER CODE END USART1_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);

  /*Configure GPIO pin : PC13 */
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : PB0 */
  GPIO_InitStruct.Pin = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

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

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
