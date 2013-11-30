obj-m+=little_secret.o
ccflags-y=-std=gnu99


all:
	make CFLAGS=-std=gnu99 -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
