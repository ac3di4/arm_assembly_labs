CROSS_COMPILE ?= aarch64-linux-gnu-

PREFIX = /opt/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

CCFLAGS = -c -g
ASFLAGS = -g
LDFLAGS = -g -static
LIBPATH = -L $(PREFIX)/lib/gcc/aarch64-linux-gnu/7.5.0 -L $(PREFIX)/aarch64-linux-gnu/libc/usr/lib
OBJPATH = $(PREFIX)/aarch64-linux-gnu/libc/usr/lib
LIBS = -lgcc -lgcc_eh -lc -lm
PREOBJ = $(OBJPATH)/crt1.o $(OBJPATH)/crti.o
POSTOBJ = $(OBJPATH)/crtn.o

SRCS = main.c
OBJS = main.o
EXE = main

C_SRCS = applym.c
C_OBJS = applymc.o

ASM_SRCS = applym.s
ASM_OBJS = applyms.o


all: $(SRCS) c_build asm_build

c_build: $(OBJS) $(C_OBJS)
	$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $(OBJS) $(C_OBJS) $(POSTOBJ) -\( $(LIBS) -\) -o $@

asm_build: $(OBJS) $(ASM_OBJS)
	$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $(OBJS) $(ASM_OBJS) $(POSTOBJ) -\( $(LIBS) -\) -o $@

clean:
	rm -rf *.o *.out

$(OBJS): $(SRCS)
	$(CC) $(CCFLAGS) -O3 $< -o $@

$(C_OBJS): $(C_SRCS)
	$(CC) $(CCFLAGS) $(C_CCFLAGS) $< -o $@

$(ASM_OBJS): $(ASM_SRCS)
	$(AS) $(ASFLAGS) $< -o $@
