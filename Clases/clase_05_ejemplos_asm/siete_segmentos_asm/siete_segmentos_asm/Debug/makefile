################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Startup/subdir.mk
-include Src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
siete_segmentos_asm.elf \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
siete_segmentos_asm.list \

OBJCOPY_BIN += \
siete_segmentos_asm.bin \


# All Target
all: siete_segmentos_asm.elf secondary-outputs

# Tool invocations
siete_segmentos_asm.elf: $(OBJS) $(USER_OBJS) C:\Users\esala\Desktop\siete_segmentos_asm\STM32F103C8TX_FLASH.ld
	arm-none-eabi-gcc -o "siete_segmentos_asm.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m3 -T"C:\Users\esala\Desktop\siete_segmentos_asm\STM32F103C8TX_FLASH.ld" --specs=nosys.specs -Wl,-Map="siete_segmentos_asm.map" -Wl,--gc-sections -static --specs=nano.specs -mfloat-abi=soft -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

siete_segmentos_asm.list: $(EXECUTABLES)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "siete_segmentos_asm.list"
	@echo 'Finished building: $@'
	@echo ' '

siete_segmentos_asm.bin: $(EXECUTABLES)
	arm-none-eabi-objcopy  -O binary $(EXECUTABLES) "siete_segmentos_asm.bin"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) *
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST) $(OBJCOPY_BIN)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
