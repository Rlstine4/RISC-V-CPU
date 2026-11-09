#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define NUM_OF_ADDRESSES 1024


/*

    Patterns:

            0: [0, 0, 1023, 0]

            slapjack 73 6C 61 70 6A 61 63 6B: (875, 0, 1023, 875)
            chowchow 63 68 6F 77 63 68 6F 77: (887, 0, 1023, 887)


*/

int main()
{

    uint16_t MASK_10_BIT = 0x00000000000003FF;

    uint64_t data_in = 0xFFFFFFFFFFFFFFFF;
     //uint64_t data_in = 0;

    printf("Data_in: %d \n", data_in);

    uint16_t data_in_LOW  = data_in &   (0x000000000000FFFF);
    uint16_t data_in_knuth = data_in &  (0x00000000FFFF0000);
    uint16_t data_in_invert = data_in & (0x0000FFFF00000000);
    uint16_t data_in_HIGH = data_in &   (0xFFFF000000000000);


    uint16_t mod_out = ( data_in_LOW % NUM_OF_ADDRESSES );
    uint16_t knuth_out = ( (data_in_knuth * (data_in_knuth + 3)) % NUM_OF_ADDRESSES );
    uint16_t invert_out = (~data_in_invert) & MASK_10_BIT;
    uint16_t xor_out    = (data_in_HIGH ^ data_in_LOW);
    uint16_t shift_out  = (data_in_invert << 1);

    printf("Mod index = %d \n", mod_out & MASK_10_BIT);
    //printf("Knuth index = %d \n", knuth_out & MASK_10_BIT);
    printf("Invert index = %d \n", invert_out);
    printf("XOR index = %d \n", xor_out & MASK_10_BIT);
    //printf("SHIFT index = %d \n", shift_out & MASK_10_BIT);


}