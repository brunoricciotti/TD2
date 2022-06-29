################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Core/tareas/cambiatarea.s 

C_SRCS += \
../Core/tareas/tareas.c 

OBJS += \
./Core/tareas/cambiatarea.o \
./Core/tareas/tareas.o 

S_DEPS += \
./Core/tareas/cambiatarea.d 

C_DEPS += \
./Core/tareas/tareas.d 


# Each subdirectory must supply rules for building sources it contributes
Core/tareas/cambiatarea.o: ../Core/tareas/cambiatarea.s
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 -c -x assembler-with-cpp -MMD -MP -MF"Core/tareas/cambiatarea.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"
Core/tareas/tareas.o: ../Core/tareas/tareas.c
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F103xB -DDEBUG -c -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"Core/tareas/tareas.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

