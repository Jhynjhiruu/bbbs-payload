TARGET = payload

# CC = $(N64_INST)/bin/mips64-elf-gcc
# LD = $(N64_INST)/bin/mips64-elf-ld
# LD = ld.lld
CC = mips-n64-gcc
AS = mips-n64-as
LD = mips-n64-ld

# OBJCOPY = $(N64_INST)/bin/mips64-elf-objcopy
OBJCOPY = mips-n64-objcopy

CUR = $(shell pwd)

$(TARGET): payload.o invalicache.o writebackdcache.o save.o
	$(LD) -o tmp --script=linker.ld -Map $(TARGET).map $^
	$(OBJCOPY) --dump-section .text=$@ tmp

%.o: %.c
	$(CC) -o $@ -c $< -O2 -nostdlib -nostartfiles -fno-builtin -mips3 -mabi=32 -ffreestanding -mfix4300

%.o: %.s
	$(AS) -o $@ $< -mips3 -march=vr4300 -mabi=32

%.o: %.bin
	$(OBJCOPY) -I binary -O elf32-bigmips $< $@

clean:
	-rm $(TARGET)
	-rm payload.o invalicache.o writebackdcache.o save.o

nand: $(TARGET)
	(cd ../rust/bbbs && cargo run -- --sksa 1009 --virage2 v2.bin --bootrom bootrom.bin $(CUR)/$(TARGET))
	../SKSA_upgrader/iQueTool.exe nand -uk $(TARGET).sksa -gs spare.bin -o nand.bin ../rust/nimu/nand.bin