#include <stdint.h>
#include <stdio.h>

#define NUM_OF_ADDRESSES 1024

int main()
{

    uint16_t MASK_10_BIT = 0x00000000000003FF;

    uint64_t data_in = 8096;

    printf("Data_in: %d \n", data_in);

    uint16_t data_in_LOW  = data_in &   (0x000000000000FFFF);
    uint16_t data_in_knuth = data_in &  (0x00000000FFFF0000);
    uint16_t data_in_invert = data_in & (0x0000FFFF00000000);
    uint16_t data_in_HIGH = data_in &   (0xFFFF000000000000);


    uint16_t mod_out = ( data_in_LOW % NUM_OF_ADDRESSES ) & MASK_10_BIT;
    uint16_t knuth_out = ( (data_in_knuth * (data_in_knuth + 3)) % NUM_OF_ADDRESSES ) & MASK_10_BIT;
    uint16_t invert_out = (~data_in_invert) & MASK_10_BIT;
    uint16_t xor_out    = (data_in_HIGH ^ data_in_LOW) & MASK_10_BIT;

    printf("Mod index = %d \n", mod_out);
    printf("Knuth index = %d \n", knuth_out);
    printf("Invert index = %d \n", invert_out);
    printf("XOR index = %d \n", xor_out);


}