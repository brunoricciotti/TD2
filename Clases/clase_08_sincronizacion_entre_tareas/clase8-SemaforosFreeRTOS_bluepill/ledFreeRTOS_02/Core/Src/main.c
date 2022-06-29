#include "main.h"
#include "cmsis_os.h"

void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void StartDefaultTask(void const * argument);

void TareaLed(void *p);
void TareaTiempo(void *p);
void TareaMutex(void *p);
void ChocarCalesita(void);

//Ejemplo de pasaje de parámetros.
typedef struct
{
	int *var;
	int comportamiento;
	xSemaphoreHandle mutex;
} pTareaMutex;


//Semáforo para sincronizar tareas.
xSemaphoreHandle semToggleLed;

//Semáforo para mutua exclusión.
xSemaphoreHandle semMutexVariables;

//Variable global para compartir (prolijamente)
int comparte = 0;
pTareaMutex par[3];

int main(void)
{
	int i;

	HAL_Init();
	SystemClock_Config();
	MX_GPIO_Init();

	//Creo el semáforo y si no puedo falla el sistema
	if(!(semToggleLed = xSemaphoreCreateBinary()))
	{
		ChocarCalesita();
	}

	//Creo un mutex.
	if(!(semMutexVariables = xSemaphoreCreateMutex()))
	{
		ChocarCalesita();
	}

	xTaskCreate(TareaLed,
		  	  "tarea_led",
			  128,
			  NULL,
			  1,
			  NULL);

	xTaskCreate(TareaTiempo,
		  	  "tarea_tiempo",
			  128,
			  NULL,
			  1,
			  NULL);

	par[0].var = &comparte;
	par[0].mutex = semMutexVariables;
	par[0].comportamiento = 1;
	par[1].var = &comparte;
	par[1].mutex = semMutexVariables;
	par[1].comportamiento = -1;
	par[2].var = &comparte;
	par[2].mutex = semMutexVariables;
	par[2].comportamiento = 2;


	for(i=0;i<3;i++)
	{
		if(xTaskCreate(TareaMutex,
				  	  "tarea_mutex",
					  128,
					  &par[i],
					  1,
					  NULL) != pdPASS)
		{
			ChocarCalesita();
		}
	}


   vTaskStartScheduler();
   ChocarCalesita();
   return 1;
}

void TareaLed(void *p)
{
	while(1)
	{
		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
		if(xSemaphoreTake(semToggleLed,portMAX_DELAY)!=pdTRUE)
		{
			//Salí por timeout o por error.
			//me la doy en la pera.
			ChocarCalesita();
		}
	}
}

void TareaTiempo(void *p)
{
	while(1)
	{
		vTaskDelay(250);
		xSemaphoreGive(semToggleLed);
	}
}

void TareaMutex(void *p)
{
	pTareaMutex *par = (pTareaMutex*)p;
	while(1)
	{
		xSemaphoreTake(par->mutex,portMAX_DELAY);
			//Zona de mutua exclusión.
			*(par->var) += par->comportamiento;
		xSemaphoreGive(par->mutex);
		vTaskDelay(2);

	}
}


void ChocarCalesita(void)
{
	volatile int32_t i;
	__disable_irq();
	while(1)
	{
		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
		for(i=0;i<200000; i++);
	}
}

void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the CPU, AHB and APB busses clocks 
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
  /** Initializes the CPU, AHB and APB busses clocks 
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

static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);

  /*Configure GPIO pin : PC13 */
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

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
  if (htim->Instance == TIM1) {
    HAL_IncTick();
  }
}

void Error_Handler(void)
{
}
