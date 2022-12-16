/*
 * coffee_flash.c
 *
 *  Created on: 16.1.2015
 *      Author: hleppine
 */

#include "coffee_flash.h"
#include "cfs-coffee-arch.h"

#include <stdio.h>


/*
 * https://github.com/contiki-os/contiki/wiki/File-systems#Porting_Coffee:
 * "Note that Coffee considers 0x00 to be the erased value of a byte rather than
 * 0xFF (which is the erased value in an actual flash). Because of this, you
 * may need your read function to invert the bits of data read from flash, and
 * your write function invert them before writing to flash."
 */


/*
 * NOTE: THIS IS A SIMULATION FOR LINUX
 */

const char* diskname = "coffeedisk.img";

#define TRUE 1
#define FALSE 0


/* Return TRUE if file exists, otherwise FALSE */
static void create_file_if_needed(const char * const filename){

    FILE * pFile;

    pFile = fopen(diskname, "r");
    if(pFile == NULL){

        pFile = fopen(diskname, "w");
        if(pFile != NULL){
        fclose(pFile);
        }

    } else {
        fclose(pFile);
    }

}


void cflash_write(const uint8_t * const buf, uint32_t size, uint32_t offset){

    FILE * pFile;

    create_file_if_needed(diskname);

    pFile = fopen(diskname, "rb+");

    if(pFile != NULL){

        // Go to correct position
        fseek(pFile, offset, SEEK_SET);

        for (uint32_t i = 0; i < size; i++){
            fputc(buf[i], pFile);
        }

        fclose(pFile);

    }

}


void cflash_read(uint8_t* buf, uint32_t size, uint32_t offset){
    
    FILE * pFile;

    create_file_if_needed(diskname);

    pFile = fopen(diskname, "rb");

    if(pFile != NULL){

        // Go to correct position
        fseek(pFile, offset, SEEK_SET);

        for (uint32_t i = 0; i < size; i++){
            buf[i] = fgetc(pFile);
        }

        fclose(pFile);

    }

}


void cflash_erase(uint16_t sector){

    const uint8_t zeroes[COFFEE_SECTOR_SIZE] = {0};

    cflash_write(zeroes, COFFEE_SECTOR_SIZE, COFFEE_SECTOR_SIZE*sector);    

}


