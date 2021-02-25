# export USE_QEMU=1
# make

# export USE_QEMU=
# make

ARMGNU ?= aarch64-linux-gnu

COPS = -Wall -nostdlib -nostartfiles -ffreestanding -Iinclude -mgeneral-regs-only -g -O0 
ASMOPS = -Iinclude  -g 

ifeq ($(USE_QEMU),1)
	COPS += -DUSE_QEMU=1
	ASMOPS += -DUSE_QEMU=1
	START_ADDR = 0x80000
	BUILD_DIR = build-qemu
else
	BUILD_DIR = build-rpi
	START_ADDR = 0x0
endif

SRC_DIR = src

all : kernel8.img

clean :
	rm -rf $(BUILD_DIR) *.img 

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

$(BUILD_DIR)/linker.ld : $(SRC_DIR)/linker.in.ld
	mkdir -p $(@D)
	$(ARMGNU)-gcc -E -DSTART_ADDR=$(START_ADDR) -x c $^ | grep -v '^#' > $@	

kernel8.img: $(BUILD_DIR)/linker.ld $(OBJ_FILES)
	$(ARMGNU)-ld -T $(BUILD_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
