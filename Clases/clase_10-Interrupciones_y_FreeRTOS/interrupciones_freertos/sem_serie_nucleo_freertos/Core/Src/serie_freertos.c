#include "main.h"
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

static UART_HandleTypeDef *mi_uart;
static xSemaphoreHandle semaforo_tx;
static xSemaphoreHandle semaforo_rx;


void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
	BaseType_t p;
	UNUSED(huart);
	xSemaphoreGiveFromISR(semaforo_tx,&p);
	portEND_SWITCHING_ISR(p);
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	BaseType_t p;
	UNUSED(huart);
	xSemaphoreGiveFromISR(semaforo_rx,&p);
	portEND_SWITCHING_ISR(p);
}



void serieFreeRTOS_inicializar(UART_HandleTypeDef *huart)
{
	mi_uart = huart;
	semaforo_rx = xSemaphoreCreateBinary();
	semaforo_tx = xSemaphoreCreateBinary();
	xSemaphoreTake(semaforo_rx,0);
	xSemaphoreTake(semaforo_tx,0);
}

void serieFreeRTOS_gets(uint8_t *datos, uint32_t len)
{
	HAL_UART_Receive_IT(mi_uart, datos, len);
	xSemaphoreTake(semaforo_rx,portMAX_DELAY);
}

void serieFreeRTOS_puts(uint8_t *datos, uint32_t len)
{
	HAL_UART_Transmit_IT(mi_uart, datos, len);
	xSemaphoreTake(semaforo_tx,portMAX_DELAY);
}
