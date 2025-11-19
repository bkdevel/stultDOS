INCLUDE = ./include
SRC = ./src
BUILD = ./bin

ASM = nasm
CC = bcc						# Bruce's C Compiler
LD = ld86
LDFLAGS = -d
CFLAGS = -I$(INCLUDE) -c -W -ansi -0
ASMFLAGS = -f as86



.PHONY: bootloader kernel image clean all always run
bootloader: $(BUILD)/boot.bin
kernel: $(BUILD)/kernel.bin
image: $(BUILD)/disk.img

all: image run

always:
	mkdir -p $(BUILD)
	touch $(BUILD)/placeholder

run: always
	qemu-system-i386 -fda $(BUILD)/disk.img

$(BUILD)/boot.bin: always
	$(ASM) $(SRC)/boot.s -f bin -o $(BUILD)/boot.bin

$(BUILD)/kernel.bin: always
	$(ASM) $(SRC)/kernel.s $(ASMFLAGS) -o $(BUILD)/kernel.s.o
	file $(BUILD)/kernel.s.o
	$(CC) $(CFLAGS) $(SRC)/kernel.c -o $(BUILD)/kernel.c.o
	file $(BUILD)/kernel.c.o
	$(LD) $(LDFLAGS) $(BUILD)/kernel.s.o $(BUILD)/kernel.c.o -o $(BUILD)/kernel.bin
	file $(BUILD)/kernel.bin
	


$(BUILD)/disk.img: always bootloader kernel
	dd if=/dev/zero of=$(BUILD)/disk.img bs=512 count=2880
	sudo mkfs.fat -F12 -n "STDOS" $(BUILD)/disk.img
	dd if=$(BUILD)/boot.bin of=$(BUILD)/disk.img conv=notrunc
	mcopy -i $(BUILD)/disk.img $(BUILD)/kernel.bin "::kernel.bin"

clean: always
	rm $(BUILD)/*
