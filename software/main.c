//=====================================================================
// Description:
// Software driver
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 5.30 Initial version, Huang Chaofan
// ====================================================================
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"

#define MEM0_OFFSET          (0x00000)
#define MEM1_OFFSET          (0x08000)
#define MEM2_OFFSET          (0x10000)
#define MEM3_OFFSET          (0x18000)

#define START_OFFSET         (0x20000)
#define DONE_OFFSET          (0x20004)
#define INPUT_BASE_OFFSET    (0x20008)
#define OUTPUT_BASE_OFFSET   (0x2000c)

#define RESULT_OFFSET        (0x06000)


int main(void)
{
    srand(__get_rv_cycle()  | __get_rv_instret() | __RV_CSR_READ(CSR_MCYCLE));

    printf("Hello World From RISC-V Processor!\n");
    int i, j;
	// Stage 1: data write
	volatile uint32_t *mem0_ptr = (uint32_t *)(MHSA_CFG_BASE + MEM0_OFFSET);
    volatile uint32_t *mem1_ptr = (uint32_t *)(MHSA_CFG_BASE + MEM1_OFFSET);
    volatile uint32_t *mem2_ptr = (uint32_t *)(MHSA_CFG_BASE + MEM2_OFFSET);
    volatile uint32_t *mem3_ptr = (uint32_t *)(MHSA_CFG_BASE + MEM3_OFFSET);
    volatile uint32_t *mem0_start_ptr = mem0_ptr;
    volatile uint32_t *mem1_start_ptr = mem1_ptr;
    volatile uint32_t *mem2_start_ptr = mem2_ptr;
    volatile uint32_t *mem3_start_ptr = mem3_ptr;
    for (i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            *mem0_ptr = rand();
            mem0_ptr++;
        }
    }
	for (i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            *mem1_ptr = rand();
            mem1_ptr++;
        }
    }
	for (i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            *mem2_ptr = rand();
            mem2_ptr++;
        }
    }
	for (i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            *mem3_ptr = rand();
            mem3_ptr++;
        }
    }
	for (i = 0; i < 128; i++) {
        for (j = 0; j < 8; j++) {
            *mem0_ptr = rand();
            mem0_ptr++;
        }
    }
    mem0_ptr = mem0_start_ptr;
    mem1_ptr = mem1_start_ptr;
    mem2_ptr = mem2_start_ptr;
    mem3_ptr = mem3_start_ptr;
    printf("Wo matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            printf("%08X ",  *mem0_ptr);
            mem0_ptr++; 
        }
        printf("\n");
    }
    printf("\n");
    printf("Wq matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            printf("%08X ",  *mem1_ptr);
            mem1_ptr++; 
        }
        printf("\n");
    }
    printf("\n");
    printf("Wk matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            printf("%08X ",  *mem2_ptr);
            mem2_ptr++; 
        }
        printf("\n");
    }
    printf("\n");
    printf("Wv matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 32; j++) {
            printf("%08X ",  *mem3_ptr);
            mem3_ptr++; 
        }
        printf("\n");
    }
    printf("\n");
    printf("Input_x matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 8; j++) {
            printf("%08X ",  *mem0_ptr);
            mem0_ptr++; 
        }
        printf("\n");
    }
    printf("\n");
	printf("Data written to memory.\n");

	// Stage 2: MHSA compute
    volatile uint32_t *start_ptr = (uint32_t *)(MHSA_CFG_BASE + START_OFFSET);
    volatile uint32_t *done_ptr = (uint32_t *)(MHSA_CFG_BASE + DONE_OFFSET);
    
    *start_ptr = 1; // Trigger the MHSA compute operation
	printf("MHSA compute operation starts.\n");
    while (*done_ptr == 0) {
        // Wait for the compute operation to complete
    }
    //*start_ptr = 0; // Reset the start signal
    printf("MHSA compute operation completed.\n");

	// Stage 3: result output
    volatile uint32_t *result_ptr = (uint32_t *)(MHSA_CFG_BASE + RESULT_OFFSET);
    printf("Result matrix is:\n");
    for(i = 0; i < 128; i++) {
        for (j = 0; j < 8; j++) {
            printf("%08X ",  *result_ptr);
            result_ptr++; 
        }
        printf("\n");
    }
	printf("Test finished.");
	return 0;
    

}
