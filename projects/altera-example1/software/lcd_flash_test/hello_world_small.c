/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include <stdio.h>
#include <stdint.h>
#include <system.h>
#include "altera_avalon_pio_regs.h"
#include <io.h>
#include "sys/alt_flash.h"
#include "sys/alt_flash_dev.h"

unsigned char picture[];

enum cmd {
	CMD_NOP = 0, CMD_HOME, CMD_SET_X, CMD_SET_Y, CMD_SET_XY, CMD_SET_P
};
#define DATA_BIT	0
#define CMD_BIT		16
#define STEP_BIT	31

void write_data(uint8_t cmd, uint16_t data) {
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_LCD_CONTROL_BASE,
			(0 << STEP_BIT) | (cmd << CMD_BIT) | data);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_LCD_CONTROL_BASE,
			(1 << STEP_BIT) | (cmd << CMD_BIT) |data);
}
// 565
// 5 4..0
// 11 10..5
// 15..11
void write_pixel(uint8_t r, uint8_t g, uint8_t b) {
	write_data(CMD_SET_P,
			((r & 0x1F) << 11) | ((g & 0x3F) << 5) | ((b & 0x1F) << 0));
}
void delay() {
	int delay = 0;
	while (delay < 2000) {
		delay++;
	}
}
int test() {

	alt_flash_fd* my_epcs;
	char my_data[256];
	memset(my_data, 0xFF, 256);

	//check your (EPCS_CONTROLLER_NAME) from system.h
	my_epcs = alt_flash_open_dev(
			INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_NAME);

	if (my_epcs) {
		printf("EPCS opened successfully!\n");

		//example application, read general data from epcs address 0x70000
		int ret_code = alt_read_flash(my_epcs, 0, my_data, 256);
		if (!ret_code) {
			for (int add = 0; add < 256; add += 16) {
				printf("0x%04x:\t", add);
				for (int i = 0; i < 16; i++) {
					printf("%02x ", 0xFF & my_data[add + i]);
				}
				printf("\n");
			}
		} else {
			printf("Error! Reading");
			return -1;
		}
	} else {
		printf("Error! EPCS not opened!");
		return -2;
	}
}
#define FLASH_STEP 64
#define FLASH_START_ADD 0x1F2E200
//0x0007CB88*FLASH_STEP
#include <sys/alt_sys_init.h>
//38400 -> bytes
int main() {
	alt_putstr("Hello small from Nios II!\n");
	int *p = SDRAM_CONTROLLER_BASE;

	for(int i = SDRAM_CONTROLLER_BASE; i < SDRAM_CONTROLLER_BASE + 1024; ++i){
		*p = i;
		printf("add 0x%08x:0x%08x\n", i, *p);
		p++;
	}


	//return test();
	printf("Device ID: %x\n", read_device_id());
	printf("Status reg: %x\n", read_status_register());
	enter_4byte_addressing_mode();
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000101);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x5,0x00000003);

	for (int add = FLASH_START_ADD; add < (FLASH_START_ADD + FLASH_STEP*240*400*2); add += FLASH_STEP*2) {
		int value1 = 0xFF&IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,add);
		int value2 = 0xFF&IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,add+FLASH_STEP);
		write_data(CMD_SET_P, (value1 << 8) | (value2 << 0));
		//printf("%08x: %02x\n",add/FLASH_STEP,0xff&value);
	}

	printf("printf test!\n");
	return 0;
}
