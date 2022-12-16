avr-objcopy -O ihex -R .eeprom Debug/cyclic_executive.elf Debug/cyclic_executive.hex
avrdude -F -V -c arduino -p ATMEGA328P -P /dev/ttyACM0 -b 115200 -U flash:w:Debug/cyclic_executive.hex
