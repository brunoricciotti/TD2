#include "main.h"
#include "cmsis_os.h"

void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void StartDefaultTask(void const * argument);

void TareaLed(void *p);
void TareaTiempo(void *p);
void ChocarCalesita(void);
uint32_t GenerarRandom(void);


//Cola para avisar que terminé.
xQueueHandle cola_todo_piola;

//Cola para pasar el proximo tiempo
xSemaphoreHandle cola_tiempo;


int main(void)
{
	HAL_Init();
	SystemClock_Config();
	MX_GPIO_Init();

	//Cola que avisa cuando termina una espera.
	if(!(cola_todo_piola = xQueueCreate(1,sizeof(uint8_t))))
	{
		ChocarCalesita();
	}

	//Cola que pasa el tiempo de espera.
	if(!(cola_tiempo = xQueueCreate(2,sizeof(uint16_t))))
	{
			ChocarCalesita();
	}

	if(xTaskCreate(TareaLed,
		  	  "tarea_led",
			  128,
			  NULL,
			  1,
			  NULL)!= pdPASS) ChocarCalesita();

	if(xTaskCreate(TareaTiempo,
		  	  "tarea_tiempo",
			  128,
			  NULL,
			  1,
			  NULL)!=pdPASS) ChocarCalesita();

   vTaskStartScheduler();
   ChocarCalesita();
   return 1;
}

void TareaLed(void *p)
{
	uint16_t item;
	uint8_t ok = 0;
	while(1)
	{

		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
		xQueueReceive(cola_tiempo, &item, portMAX_DELAY);
		vTaskDelay(item);
		xQueueSend(cola_todo_piola,&ok,portMAX_DELAY);
	}
}

void TareaTiempo(void *p)
{
	uint32_t r;
	uint16_t datoCola;
	while(1)
	{
		do{
			r = GenerarRandom();
			r&=0x1FF;
		}while(r>=50 && r<=500);
		datoCola = (uint16_t)r;
		xQueueSend(cola_tiempo,&datoCola,portMAX_DELAY);
		xQueueReceive(cola_todo_piola, &datoCola, portMAX_DELAY);
	}
}

uint32_t GenerarRandom(void)
{
	//https://www.jstatsoft.org/index.php/jss/article/view/v008i14/xorshift.pdf
	static uint32_t x = 0x11223344;
	static uint32_t y = 0x55667788;
	static uint32_t z = 0x99AABBCC;
	static uint32_t w = 0xDDEEFF00;
	uint32_t tmp=(x^(x<<15));
	x=y;
	y=z;
	z=w;
	return w=(w^(w>>21))^(tmp^(tmp>>4));
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
