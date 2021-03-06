/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under Ultimate Liberty license
  * SLA0044, the "License"; You may not use this file except in compliance with
  * the License. You may obtain a copy of the License at:
  *                             www.st.com/SLA0044
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "cmsis_os.h"
#include "task.h"

/* Private includes ----------------------------------------------------------*/

TaskHandle_t task1,task2,task_pulsadores;

/* Private variables ---------------------------------------------------------*/
/* Definitions for defaultTask */
osThreadId_t defaultTaskHandle;
const osThreadAttr_t defaultTask_attributes = {
  .name = "defaultTask",
  .priority = (osPriority_t) osPriorityNormal,
  .stack_size = 128 * 4
};
/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void StartDefaultTask(void *argument);
void xorshift_inic(uint32_t s);
uint32_t xorshift(void);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
void setear_led(int n_led, int estado)
{
	switch(n_led)
	{
		case 0: HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7, (estado)?GPIO_PIN_SET:GPIO_PIN_RESET); break;
		case 1: HAL_GPIO_WritePin(GPIOB, GPIO_PIN_9, (estado)?GPIO_PIN_SET:GPIO_PIN_RESET); break;
	}
}

void tarea_LED1()
{
	for(;;){

		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7,GPIO_PIN_SET);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_9,GPIO_PIN_RESET);
		vTaskPrioritySet(task_pulsadores,3);//vuelvo a leer pulsadores
	}
}
void tarea_LED2()
{
	for(;;){

		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7,GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_9,GPIO_PIN_SET);
		vTaskPrioritySet(task_pulsadores,3);//vuelvo a leer pulsadores
	}
}

void tarea_pulsadores()
{
	static uint16_t vez = 1;
	uint32_t res,seed = 100;

	for(;;)
	{
		if(!HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_0)){//entra si el pulsador 1 esta presionado

			if(vez%2)//si vez es par, no entra
			{
				vez++;
				vTaskPrioritySet(task1, 2);//Hago que la prioridad de task1 sea 2
				vTaskPrioritySet(task2, 1);//Hago que la prioridad de task2 sea 1
				vTaskPrioritySet(NULL,1);//Le bajo la prioridad para que se ejecute la otra

			}
			else
			{
				vez++;
				vTaskPrioritySet(task1, 1);//Hago que la prioridad de task1 sea 1
				vTaskPrioritySet(task2, 2);//Hago que la prioridad de task2 sea 2
				vTaskPrioritySet(NULL,1);//Le bajo la prioridad para que se ejecute la otra
			}
		}

		if(!HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_1)){//entra si el pulsador 2 esta presionado

			xorshift_inic(seed);//semilla
			res = xorshift();

			//hago que los valores de res vayan de 0 a 2
			if(res % 5){
				res = 0;//si no es divisible por 5 res = 0
			}
			else if(!(res % 2)){
				res = 1;
			}
			else res = 2;

			if(res == 0){
				vTaskPrioritySet(task1, 1);//Hago que la prioridad de task1 sea 1
				vTaskPrioritySet(task2, 1);//Hago que la prioridad de task2 sea 1
			}
			else if(res == 1){
				vTaskPrioritySet(task1, 1);//Hago que la prioridad de task1 sea 1
				vTaskPrioritySet(task2, 2);//Hago que la prioridad de task2 sea 2
				vTaskPrioritySet(NULL,1);//Le bajo la prioridad para que se ejecute la otra
			}
			else{
				vTaskPrioritySet(task1, 2);//Hago que la prioridad de task1 sea 2
				vTaskPrioritySet(task2, 1);//Hago que la prioridad de task2 sea 1
				vTaskPrioritySet(NULL,1);//Le bajo la prioridad para que se ejecute la otra
			}

			seed = seed*(seed+res+1);//cambio la semilla
		}
			/*vTaskPrioritySet(task2, 1);//Hago que la prioridad sea la mas alta para que
			boton = 2;											 //al desploquearse los task anteriores no cambie los LED
		}
		else if(boton == 2){

			vTaskPrioritySet(task2, 3);//Hago que la prioridad sea mas baja para que al desbloquarse el task cambie los LED
			boton = 0;//si entro aca me olvido del boton
		}*/
	}
}

void findelprograma(void)
{
	volatile int32_t i;
	__disable_irq();
	while(1)
	{
		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
		for(i=0;i<200000; i++);
	}
}
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
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */
  //setear_led(0, 1);
  // setear_led(1, 0);
  /* Init scheduler */
  osKernelInitialize();


  if(xTaskCreate(tarea_LED1,
   		  	  	  "tarea_LED1",
				  128,
 			      NULL,
				  1,
				  &task1)!= pdPASS) findelprograma();

  if(xTaskCreate(tarea_LED2,
  		  	  	  "tarea_LED2",
				  128,
				  NULL,
				  1,
				  &task2)!= pdPASS) findelprograma();


  if(xTaskCreate(tarea_pulsadores,
		   	   	  "tarea_pulsadores",
				  128,
				  NULL,
				  3,
				  &task_pulsadores)!= pdPASS) findelprograma();


  /* Create the thread(s) */
  /* creation of defaultTask */
//  defaultTaskHandle = osThreadNew(StartDefaultTask, NULL, &defaultTask_attributes);

  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* Start scheduler */
  osKernelStart();

  /* We should never get here as control is now taken by the scheduler */
  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
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

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL2;
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
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
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
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7|GPIO_PIN_9, GPIO_PIN_RESET);

  /*Configure GPIO pins : PB0 PB1 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PB7 PB9 */
  GPIO_InitStruct.Pin = GPIO_PIN_7|GPIO_PIN_9;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/* USER CODE BEGIN Header_StartDefaultTask */
/**
  * @brief  Function implementing the defaultTask thread.
  * @param  argument: Not used
  * @retval None
  */
/* USER CODE END Header_StartDefaultTask */
void StartDefaultTask(void *argument)
{
  /* USER CODE BEGIN 5 */
  /* Infinite loop */
  for(;;)
  {
    osDelay(1);
  }
  /* USER CODE END 5 */
}

/**
  * @brief  Period elapsed callback in non blocking mode
  * @note   This function is called  when TIM1 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM1) {
    HAL_IncTick();
  }
  /* USER CODE BEGIN Callback 1 */

  /* USER CODE END Callback 1 */
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */

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
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
