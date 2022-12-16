CC=gcc
CFLAGS=-Wall -pedantic -std=c99
LDFLAGS=-lm
INCLUDE=stubs
SOURCES=cfstest.c coffee_fs/cfs-coffee.c coffee_fs/coffee_flash.c coffee_fs/test-coffee.c stubs/os_task.c
EXECUTABLE=build/cfstest

all:
	mkdir -p build
	$(CC) -o $(EXECUTABLE) -I$(INCLUDE) $(CFLAGS) $(SOURCES) $(LDFLAGS)


