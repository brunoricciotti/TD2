#include "arrebote.h"

void inicializar_arrebote(arrebote *s, uint8_t activo_en_cero, uint16_t debounce)
{
	s->debounce = debounce;
	s->debounce_ticks=0;
	s->activo_en_cero = (activo_en_cero)?1:0;
	s->estado = 0;
	s->estado_pin = (uint8_t)BTN_LIBRE;
	s->estado_anterior_pin = (uint8_t)BTN_PRESIONADO;
}

void chequear_arrebote(arrebote *s, uint32_t estado)
{
	int boton;
	boton = (estado) ? 1 : 0;
	boton = boton ^ s->activo_en_cero;

	switch (s->estado)
	{
	case 0:
		if (boton)
		{
			s->debounce_ticks = s->debounce;
			s->estado = 1;
		}
		s->estado_pin = BTN_LIBRE;
		s->estado_anterior_pin = BTN_LIBRE;
		break;
	case 1:
		if (!(--(s->debounce_ticks)))
		{
			if (boton)
			{
				s->estado_pin = BTN_PRESIONADO;
				s->estado_anterior_pin = BTN_LIBRE;
				s->estado = 2;
			}
			else
			{
				s->estado = 0;
			}
		}
		break;
	case 2:
		if (!boton)
		{
			s->debounce_ticks = s->debounce;
			s->estado = 3;
		}
		s->estado_pin = BTN_PRESIONADO;
		s->estado_anterior_pin = BTN_PRESIONADO;
		break;
	case 3:
		if (!(--(s->debounce_ticks)))
		{
			if (!boton)
			{
				s->estado_pin = BTN_LIBRE;
				s->estado_anterior_pin = BTN_PRESIONADO;
				s->estado = 0;
			}
			else
			{
				s->estado = 2;
			}
		}
		break;
	}
}

int hay_flanco_arrebote(arrebote *s)
{
	return (s->estado_pin == BTN_PRESIONADO) && (s->estado_anterior_pin == BTN_LIBRE);
}

arrebote_estado_boton estado_boton_arrebote(arrebote *s)
{
	return s->estado_pin;
}


