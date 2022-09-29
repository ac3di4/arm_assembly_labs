CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = prog2.s
OBJS = $(SRCS:.s=.o)

EXE = prog2

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@
	
.PHONY: ltoh
ltoh:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS) --defsym LTOH=1
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

.PHONY: htol
htol:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS) --defsym HTOL=1
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)
