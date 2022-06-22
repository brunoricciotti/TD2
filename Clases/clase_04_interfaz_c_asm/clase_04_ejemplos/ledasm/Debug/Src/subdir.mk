################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/led.s 

OBJS += \
./Src/led.o 

S_DEPS += \
./Src/led.d 


# Each subdirectory must supply rules for building sources it contributes
Src/led.o: ../Src/led.s
	arm-none-eabi-gcc -mcpu=cortex-m3 -g3 -c -x assembler-with-cpp -MMD -MP -MF"Src/led.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

