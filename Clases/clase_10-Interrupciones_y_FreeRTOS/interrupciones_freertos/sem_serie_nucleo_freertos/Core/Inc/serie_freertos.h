/*
 * serie_freertos.h
 *
 *  Created on: Jun 7, 2021
 *      Author: esala
 */

#ifndef INC_SERIE_FREERTOS_H_
#define INC_SERIE_FREERTOS_H_
#include "main.h"
void serieFreeRTOS_inicializar(UART_HandleTypeDef *huart);
void serieFreeRTOS_puts(uint8_t *datos, uint32_t len);
void serieFreeRTOS_gets(uint8_t *datos, uint32_t len);


#endif /* INC_SERIE_FREERTOS_H_ */
