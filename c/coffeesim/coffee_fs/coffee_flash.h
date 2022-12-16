/*
 * coffee_flash.h
 *
 *  Created on: 16.1.2015
 *      Author: hleppine
 */

#ifndef COFFEE_FLASH_H_
#define COFFEE_FLASH_H_

#include <stdint.h>


/* Write data to memory device
 * -buf:    data block to write
 * -size:   size of data block
 * -offset: location of data block in memory device
 */
void cflash_write(const uint8_t * const buf, uint32_t size, uint32_t offset);


/* Read data from memory device
 * -buf:    data block to write
 * -size:   size of data block
 * -offset: location of data block in memory device
 */
void cflash_read(uint8_t* buf, uint32_t size, uint32_t offset);


/*
 * Erase sector
 * -sector: sector number
 */
void cflash_erase(uint16_t sector);


#endif /* COFFEE_FLASH_H_ */
