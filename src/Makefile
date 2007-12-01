MY_ARCH := $(shell uname)

DC = gdc
CC = gcc
LD = ld

ifeq (${MY_ARCH},Darwin)
        CC = x86_64-pc-elf-gcc
        LD = x86_64-pc-elf-ld
	DC = x86_64-pc-elf-gdc
else
	CC = x86_64-pc-elf-gcc
        LD = x86_64-pc-elf-ld
	DC = x86_64-pc-elf-gdc
endif

CFLAGS = -nostdlib -nodefaultlibs -g -DUSE_ASSERT

DFLAGS = -nostdlib -nodefaultlibs -g -fdebug -I .
LDFLAGS = -nostdlib -nodefaultlibs -b elf64-x86-64

ASM = boot.S
DFILES = kernel.d vga.d system.d multiboot.d idt.d gdt.d lstar.d kgdb_support.d vmem.d kgdb_stub.d config.d
RTFILES := $(shell ls std/typeinfo/*.d) object.d invariant.d dstubs.d std/c/stdarg.d
APP := application.d
OBJS = $(ASM:.S=.o) $(DFILES:.d=.o) $(RTFILES:.d=.o)

KERNEL_IMG = paganos
GRUB_IMG = stage2_eltorito
GRUB_PATH = boot/grub/
GRUB_CONFIG = menu.lst
BOOT_PATH = boot/
ISO_PATH = iso/
ISO_NAME = paganos.iso

all: $(KERNEL_IMG)
	rm -f paganos.dump && x86_64-pc-elf-objdump -d -S paganos > paganos.dump
	@echo ""
	@echo "OS successfully compiled, to make a bootable CD ISO, run:"
	@echo "        make iso"

.S.o:
	$(CC) $(CFLAGS) -c $<

%.o: %.d
	$(DC) $(DFLAGS) -c $< -o $@

$(KERNEL_IMG): $(OBJS) application.o
	$(LD) $(LDFLAGS) -o $@ $(OBJS) -dN -Ttext 0x100000
	$(LD) $(LDFLAGS) -o application application.o -dN $(OBJS)

clean:
	rm -f $(OBJS) $(KERNEL_IMG) application.o

iso: all
	mkdir -p $(ISO_PATH)$(GRUB_PATH)
	cp $(GRUB_IMG) $(ISO_PATH)$(GRUB_PATH)
	cp $(GRUB_CONFIG) $(ISO_PATH)$(GRUB_PATH)
	cp $(KERNEL_IMG) $(ISO_PATH)$(BOOT_PATH)
	cp ./application $(ISO_PATH)$(BOOT_PATH)
	mkisofs -R -b $(GRUB_PATH)$(GRUB_IMG) -no-emul-boot -boot-load-size 4 -boot-info-table -o $(ISO_NAME) $(ISO_PATH)
	@echo
	@echo "ISO successfully made!"
	@echo "        qemu-system-x86_64 -cdrom paganos.iso -boot d"
	@echo "     or bochs -q"

veryclean: clean
	rm -rf $(ISO_PATH)
	rm -f $(ISO_NAME)
	rm -f ./application