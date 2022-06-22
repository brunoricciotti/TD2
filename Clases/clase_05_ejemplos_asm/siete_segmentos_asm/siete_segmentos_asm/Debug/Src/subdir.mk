################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/bcd.s \
../Src/led.s \
../Src/siete_segmentos.s 

OBJS += \
./Src/bcd.o \
./Src/led.o \
./Src/siete_segmentos.o 

S_DEPS += \
./Src/bcd.d \
./Src/led.d \
./Src/siete_segmentos.d 


# Each subdirectory must supply rules for building sources it contributes
Src/bcd.o: ../Src/bcd.s
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 -c -x assembler-with-cpp -MMD -MP -MF"Src/bcd.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"
Src/led.o: ../Src/led.s
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 -c -x assembler-with-cpp -MMD -MP -MF"Src/led.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"
Src/siete_segmentos.o: ../Src/siete_segmentos.s
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 -c -x assembler-with-cpp -MMD -MP -MF"Src/siete_segmentos.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

