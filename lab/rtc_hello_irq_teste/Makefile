CROSS_COMPILE ?= arm-linux-gnueabihf-

all2: startup.s main.c
	$(CROSS_COMPILE)as *.s -o startup.o
	$(CROSS_COMPILE)gcc -c -Wall *.c -o main.o
	$(CROSS_COMPILE)ld  -T memmap startup.o main.o -o startup
	$(CROSS_COMPILE)objcopy startup startup.bin -O binary
	$(CROSS_COMPILE)objdump -DSx -b binary -marm startup.bin > startup.lst
	cp *.bin /tftpboot


clean:
	rm *.o *.bin *.lst
