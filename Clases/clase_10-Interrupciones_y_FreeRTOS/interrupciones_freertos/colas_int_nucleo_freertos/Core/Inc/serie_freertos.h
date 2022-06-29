/*
 * serie_freertos.h
 *
 *  Created on: Jun 7, 2021
 *      Author: esala
 */

#ifndef INC_SERIE_FREERTOS_H_
#define INC_SERIE_FREERTOS_H_
#include "main.h"
void serieFreeRTOS_inicializar(UART_HandleTypeDef *huart, uint32_t len_colas);
void serieFreeRTOS_IRQ(void);
void serieFreeRTOS_putchar(uint8_t dato);
uint8_t serieFreeRTOS_getchar(void);


#endif /* INC_SERIE_FREERTOS_H_ */
