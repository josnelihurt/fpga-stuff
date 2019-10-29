/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <system.h>
#include <io.h>

#define WRITE_CYCLES 1024*1024*32
#define WRITE_DATA 0x00005555

int main()
{
  printf("Hello from Nios II!\n");
  int *p = SDRAM_BASE;
  	int nError = 0;
  	for (int i = 0; i < WRITE_CYCLES; i++) {
  		IOWR_16DIRECT(SDRAM_BASE, i, WRITE_DATA);
  		int nData = IORD_16DIRECT(SDRAM_BASE, i);
  		if (nData != WRITE_DATA) {
  			nError++;
  			printf("[ERROR] Address 0x%08x: 0x%08x\n",
  					i + SDRAM_BASE, nData);
  		}
  	}

  	printf("\n\n[FINISH] %d Addresses tested, %d errors.", WRITE_CYCLES,
  			nError);
  return 0;
}
