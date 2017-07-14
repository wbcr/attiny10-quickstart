# AVRDUDE flags
PROG := stk600
PART := t10
AVRDUDE = avrdude -c $(PROG) -p $(PART)

# GCC flags
TARGET := demo.hex
F_CPU  := 1000000
MCU    := attiny10
SOURCES := $(shell find src -type f -name *.c)
OBJECTS := $(SOURCES:.c=.o)
CFLAGS = -std=gnu99 -g -Os -Wall -DF_CPU=$(F_CPU) -mmcu=$(MCU)
LDFLAGS = -mmcu=$(MCU)

CC      := avr-gcc
OBJCOPY := avr-objcopy
SIZE    := avr-size

.PRECIOUS: $(OBJECTS) %.hex %.elf

all: $(TARGET)

upload:
	$(AVRDUDE) -U flash:w:$(TARGET)

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

%.o : %.c
	$(CC) -c $(CFLAGS) -c $< -o $@

clean:
	-rm $(OBJECTS) *.{hex,elf}
