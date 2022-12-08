/*
 * arrebote.h
 *
 *  Created on: May 24, 2021
 *      Author: esala
 */

#ifndef INC_ARREBOTE_H_
#define INC_ARREBOTE_H_
#include <stdint.h>
	typedef enum { BTN_LIBRE=0, BTN_PRESIONADO} arrebote_estado_boton;
	typedef struct {
		uint16_t debounce_ticks;
		uint16_t debounce;
		uint8_t estado;
		uint8_t estado_pin;
		uint8_t estado_anterior_pin;
		uint8_t activo_en_cero;
	} arrebote;

	void inicializar_arrebote(arrebote *s, uint8_t activo_en_cero, uint16_t debounce);
	void chequear_arrebote(arrebote *s, uint32_t estado);
	int hay_flanco_arrebote(arrebote *s);
	arrebote_estado_boton estado_boton_arrebote(arrebote *s);

#endif /* INC_ARREBOTE_H_ */
