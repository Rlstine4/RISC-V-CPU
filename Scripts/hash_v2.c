#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define NUM_OF_ADDRESSES 1024


uint32_t murmur_hash(uint32_t data)
{

data ^= data >> 16;
data *= 0x85ebca6b;
data ^= data >> 13;
data *= 0xc2b2ae35;
data ^= data >> 16;

return data;

}

int main()
{
 

    uint16_t MASK_10_BIT = 0x00000000000003FF;

    //uint64_t test_cases[3] = {0, 0x4141414141414141, 0x4445414442454546};

    uint32_t test_cases[5] = {0, 0x41414141, 0x41414141, 0x44454144, 0x42454546};

    for (int i = 0; i < 5; i++)
    {
        
        printf("MURMUR RESULT %d: %d \n", i, murmur_hash(test_cases[i]) & MASK_10_BIT);
    }

   



}