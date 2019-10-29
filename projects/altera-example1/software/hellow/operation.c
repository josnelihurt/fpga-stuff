#include "system.h"
#include <io.h>



#define AVL_SPI_BASE  INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_CSR_BASE
//                    INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE
//Register access commands

//Applicable for all flashes

int read_device_id(){
	//   AVL_SPI_BASE
	IOWR(AVL_SPI_BASE,0x7,0x0000489F);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	return IORD(AVL_SPI_BASE,0xc);
}
int read_status_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00001805);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	return IORD(AVL_SPI_BASE,0xc);
}
int read_flag_status_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00001870);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	return IORD(AVL_SPI_BASE,0xc);
}
void write_enable(){
	IOWR(AVL_SPI_BASE,0x7,0x00000006);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	IOWR(AVL_SPI_BASE,0xA,1);
}

void enter_4byte_addressing_mode(){
	IOWR(AVL_SPI_BASE,0x7,0x000000B7);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	IOWR(AVL_SPI_BASE,0xA,1);
}
void clear_flag_status_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00000050);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	IOWR(AVL_SPI_BASE,0xA,1);
}
//Applicable only for cypress flash

int read_bank_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00001816);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	return IORD(AVL_SPI_BASE,0xc);
}
//for cypress flash to enter four byte addr
void write_bank_register_enter4byte(){
	IOWR(AVL_SPI_BASE,0x7,0x00001017);
	IOWR(AVL_SPI_BASE,0xA,0x00000080);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}
//for cypress flash to enter 3 byte addr
void write_bank_register_exit4byte(){
	IOWR(AVL_SPI_BASE,0x7,0x00001017);
	IOWR(AVL_SPI_BASE,0xA,0x00000000);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}
//to check cypress flash in dual or quad mode
int read_config_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00001835);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	return IORD(AVL_SPI_BASE,0xc);
}
//for cypress flash to enter quad mode
void write_config_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00002001);
	IOWR(AVL_SPI_BASE,0xA,0x00000200);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}
//exit p_err & e_err mode
void clear_status_register(){
	IOWR(AVL_SPI_BASE,0x7,0x00001030);
	IOWR(AVL_SPI_BASE,0x8,0x1);
	IOWR(AVL_SPI_BASE,0xA,1);
}

//Applicable only for micron flash//

//for micron flash to enter quad SPI mode
void write_evcr_quad(){
	IOWR(AVL_SPI_BASE,0x7,0x00001061);
	IOWR(AVL_SPI_BASE,0xA,0x0000005f);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}
//for micron flash to enter dual SPI mode
void write_evcr_dual(){
	IOWR(AVL_SPI_BASE,0x7,0x00001061);
	IOWR(AVL_SPI_BASE,0xA,0x0000009f);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}

//Erase Commands//

void erase_sector_cypress(){
	IOWR(AVL_SPI_BASE,0x7,0x000003D8);
	IOWR(AVL_SPI_BASE,0x9,0x00000000);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}
void erase_sector_micron(){
	IOWR(AVL_SPI_BASE,0x7,0x00000420);
	IOWR(AVL_SPI_BASE,0x9,0x00000000);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}

//Read Memory Commands

int read_memory(int add){
	IOWR(AVL_SPI_BASE,0x4,0x00000000);
	IOWR(AVL_SPI_BASE,0x0,0x00000101); // Enable device and select 4 byte addressing mode
	IOWR(AVL_SPI_BASE,0x5,0x00000003); // Read Instruction register
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE,add);
}
int read_memory_3byte(){
	IOWR(AVL_SPI_BASE,0x4,0x00000000);
	IOWR(AVL_SPI_BASE,0x0,0x00000001);
	IOWR(AVL_SPI_BASE,0x5,0x00000003);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE,0x00000000);
}
//cypress 4 byte fast read (0C)
int cypress_four_byte_fast_read(){
	IOWR(AVL_SPI_BASE,0x4,0x00000000);
	IOWR(AVL_SPI_BASE,0x0,0x00000101);
	IOWR(AVL_SPI_BASE,0x5,0x000080C);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE,0x00000000);
}

//Page Program Commands

//4byte addr page program
void write_memory(){
	IOWR(AVL_SPI_BASE,0x4,0x00000000);
	IOWR(AVL_SPI_BASE,0x0,0x00000101);
	IOWR(AVL_SPI_BASE,0x6,0x00007002);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE,0x00000000,0xabcd1234);
}
void write_memory_3byte(){
	IOWR(AVL_SPI_BASE,0x4,0x00000000);
	IOWR(AVL_SPI_BASE,0x0,0x00000001);
	IOWR(AVL_SPI_BASE,0x6,0x00000502);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_AVL_MEM_BASE,0x00000000,0xabcd1234);
}
//Sector Protection Commands

//Applicable for cypress flash only

//Bit 5 & Bit 3 set of configuration register set to 1; Sector 0 of memory array is protected(TB-BP2-BP1-BP0:1-0-0-1) in status register;
void write_register_for_sector_protect_cypress(){
	IOWR(AVL_SPI_BASE,0x7,0x00002001);
	IOWR(AVL_SPI_BASE,0xA,0x0000201c);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}

void write_register_for_sector_unprotect_cypress(){
	IOWR(AVL_SPI_BASE,0x7,0x00002001);
	IOWR(AVL_SPI_BASE,0xA,0x00002000);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}

//Applicable for micron flash only

void write_register_for_sector_unprotect_micron(){
	IOWR(AVL_SPI_BASE,0x7,0x00001001);
	IOWR(AVL_SPI_BASE,0xA,0x00000000);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}

//Sector 0 of memory array is protected; (TB-BP3-BP2-BP1-BP0:1-0-0-0-1)
void write_status_register_for_block_protect_micron(){
	IOWR(AVL_SPI_BASE,0x7,0x00001001);
	IOWR(AVL_SPI_BASE,0xA,0x0000007c);
	IOWR(AVL_SPI_BASE,0x8,0x1);
}



