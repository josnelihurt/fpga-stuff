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
#define WRITE_CYCLES 1024*1024*32
#define WRITE_DATA 0x00005555

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
alt_u8 *ram = SDRAM_CONTROLLER_BASE; //+ 0x10000);

#define FLASH_STEP 64
#define FLASH_START_ADD 0x1F2E200
int main() {
	alt_putstr("Hello from Nios IIddd2!\n");
	int i;
	//memset(ram, 0, 100);
	//向 ram 中写数据，当 ram 写完以后，ram 的地址已经变为(SDRAM_BASE+0x10000+200)
//	for (i = 0; i < 100; i++) {
//		*(ram++) = i;
//	}
//	//逆向读取 ram 中的数据
//	for (i = 0; i < 100; i++) {
//		printf("0x%02x \n", *(--ram));
//	}

	int *p = SDRAM_CONTROLLER_BASE;
	int nError = 0;
	for (int i = 0; i < WRITE_CYCLES; i++) {
		IOWR_16DIRECT(SDRAM_CONTROLLER_BASE, i, WRITE_DATA);
		int nData = IORD_16DIRECT(SDRAM_CONTROLLER_BASE, i);
		if (nData != WRITE_DATA) {
			nError++;
			printf("[ERROR] Address 0x%08x: 0x%08x\n",
					i + SDRAM_CONTROLLER_BASE, nData);
		}
	}

	printf("\n\n[FINISH] %d Addresses tested, %d errors.", WRITE_CYCLES,
			nError);

	//printf("Device ID: %x\n", read_device_id());
	//printf("Status reg: %x\n", read_status_register());
	//enter_4byte_addressing_mode();
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE, 0x4,
			0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE, 0x0,
			0x00000101);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE, 0x5,
			0x00000003);

	for (int add = FLASH_START_ADD;
			add < (FLASH_START_ADD + FLASH_STEP * 240 * 400 * 2);
			add += FLASH_STEP * 2) {
		int value1 = 0xFF
				& IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,
						add);
		int value2 = 0xFF
				& IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,
						add + FLASH_STEP);
		write_data(CMD_SET_P, (value1 << 8) | (value2 << 0));
		//printf("%08x: %02x\n",add/FLASH_STEP,0xff&value);
	}

	printf("printf test!\n");

	/* Event loop never exits.
	 *
	 #include <stdio.h> //标准输入输出头文件
	 2 #include "system.h" //系统头文件
	 3 #include "alt_types.h" //数据类型头文件
	 4 #include "string.h"
	 5
	 6 //SDRAM 地址
	 7 alt_u8 *ram = (alt_u8 *)(SDRAM_BASE + 0x10000);
	 8
	 9 //---------------------------------------------------------------------------
	 10 //-- 名称 : main()
	 11 //-- 功能 : 程序入口
	 12 //-- 输入参数 : 无
	 13 //-- 输出参数 : 无
	 14 //---------------------------------------------------------------------------
	 15
	 16 int main(void){
	 17 int i;
	 18 memset(ram,0,100);
	 19 //向 ram 中写数据，当 ram 写完以后，ram 的地址已经变为(SDRAM_BASE+0x10000+200)
	 20 for(i=0;i<100;i++){
	 21 *(ram++) = i;
	 22 }
	 23 //逆向读取 ram 中的数据
	 24 for(i=0;i<100;i++){
	 25 printf("%d ",*(--ram));
	 26 }
	 27 return 0;
	 28 }
	 * */
	while (1)
		;

	return 0;
}
