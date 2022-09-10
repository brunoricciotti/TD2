/*
 * timer_monitor.h
 *
 *  Created on: Jul 1, 2020
 *      Author: esala
 */

#ifndef INC_TIMER_MONITOR_H_
#define INC_TIMER_MONITOR_H_
	#include <stdint.h>
	void inic_timer(uint32_t divisor_us);
	void start_timer(void);
	uint32_t stop_timer(void);

#endif /* INC_TIMER_MONITOR_H_ */
