
from numpy import uint16
from numpy import uint32

DEPTH = 65536
INITIAL_VECTOR = []
HASHED_INDICES = []
DMEM_VALUES = []
WORD_LIST_FILE = 'words.txt'

def coe_generator(hashed_indices = []):
    #DEPTH = int(input("Please enter Block RAM depth: "))
    WIDTH =    int(input("Please enter Block RAM width: "))
    FILENAME = input("Please enter name of .coe file: ")
    RADIX    = int(input("Please input radix (2 for binary, 8 for octal, 10 for decimal, 16 for hex): "))

    if RADIX == 2:
        FORMAT = 'binary'

    elif RADIX == 8:
        FORMAT = 'octal'

    elif RADIX == 10:
        FORMAT = 'decimal'

    else:
        FORMAT = 'hex'

    FILENAME = FILENAME.strip()

    if FILENAME[len(FILENAME) - 5] != '.coe':
        FILENAME = FILENAME + ".coe"

    #Initialize the vector all 0's and then with 1's in the proper indices

    INITIAL_VECTOR = [0] * DEPTH

    for value in hashed_indices:
        INITIAL_VECTOR[value] = 1

    with open(FILENAME, "w") as file:
        file.write("; Sample memory initialization file for Single Port Block Memory, \n")
        file.write("; v3.0 or later.\n")
        file.write(";\n")
        file.write("; This .COE file specifies initialization values for a block \n")
        file.write("; memory of depth=" + str(DEPTH) +", and width=" + str(WIDTH) + ". In this case, values are " + "\n")
        file.write("; specified in " + FORMAT + " format" + "\n")
        file.write("memory_initialization_radix=" + str(RADIX) + ";" + "\n")
        file.write("memory_initialization_vector=" + "\n")

        for idx, value in enumerate(INITIAL_VECTOR):

            if (idx != 0) and( idx % 20) == 0:
                file.write("\n")

            if idx == len(INITIAL_VECTOR) - 1:
                file.write(str(value) + ";")
            
            else:
                file.write(str(value) + ", ")
        
        utilization_rate = INITIAL_VECTOR.count(1) / DEPTH

        print("Bloom buffer utilization rate is " + str(utilization_rate) + "%")
        #print(HASHED_INDICES)
        

def coe_generator_misc(arr):
    DEPTH = int(input("Please enter Block RAM depth: "))
    WIDTH =    int(input("Please enter Block RAM width: "))
    FILENAME = input("Please enter name of .coe file: ")
    RADIX    = int(input("Please input radix (2 for binary, 8 for octal, 10 for decimal, 16 for hex): "))

    if RADIX == 2:
        FORMAT = 'binary'

    elif RADIX == 8:
        FORMAT = 'octal'

    elif RADIX == 10:
        FORMAT = 'decimal'

    else:
        FORMAT = 'hex'

    FILENAME = FILENAME.strip()

    if FILENAME[len(FILENAME) - 5] != '.coe':
        FILENAME = FILENAME + ".coe"


    with open(FILENAME, "w") as file:
        file.write("; Sample memory initialization file for Single Port Block Memory, \n")
        file.write("; v3.0 or later.\n")
        file.write(";\n")
        file.write("; This .COE file specifies initialization values for a block \n")
        file.write("; memory of depth=" + str(DEPTH) +", and width=" + str(WIDTH) + ". In this case, values are " + "\n")
        file.write("; specified in " + FORMAT + " format" + "\n")
        file.write("memory_initialization_radix=" + str(RADIX) + ";" + "\n")
        file.write("memory_initialization_vector=" + "\n")
    
        for idx, value in enumerate(arr):

            if (idx != 0) and( idx % 20) == 0:
                file.write("\n")

            if idx == len(arr) - 1:
                file.write(str(value) + ";")
            
            else:
                file.write(str(value) + ", ")



def mod_hash(data_in):

    return uint32(data_in % 65536)

def shift_hash(data_in):

    return uint32(data_in << 1)

def murmur_hash(data_in):

    return uint32( ( (data_in & 0x0000FFFF) ^ (  (data_in & 0xFFFF0000 )  >> 16 )    )  + 1)


# VERIFIED FUNCTIONALITY USING DEADBEEF, FLAPJACK, WORMHOLE

def bloom_buffering(data_in):

    UPPER_DATA = uint32(data_in >> 32) # Shift upper data down to lower 32 bits and extract these
    LOWER_DATA = uint32(data_in)

    mod_idx = uint16(mod_hash(LOWER_DATA))
    shift_idx = uint16(shift_hash(LOWER_DATA))

    murmur_idx_high = uint16(murmur_hash(UPPER_DATA))
    murmur_idx_low  = uint16(murmur_hash(LOWER_DATA))

    HASHED_INDICES.append(mod_idx)
    HASHED_INDICES.append(shift_idx)
    HASHED_INDICES.append(murmur_idx_high)
    HASHED_INDICES.append(murmur_idx_low)
    

    #print("MOD IDX: " + str(mod_idx))
    #print("SHIFT IDX: " + str(shift_idx))
    #print("LOWER MURMUR IDX: " + str(murmur_idx_low))
    #print("UPPER MURMUR IDX: " + str(murmur_idx_high))

def main():

    hex_list = []
    
    sample = ''

    with open(WORD_LIST_FILE, "r") as file:
        for word in file:
            ascii_list = [ord(c) for c in word.strip()] # Convert each character to its ASCII index
            hex_list   = [hex(c) for c in ascii_list]   # Convert each character from integer to hex
            sample = (''.join(hex_list)).replace('0x', '')
            sample = '0x' + sample
            #DMEM_VALUES.append(sample)
            bloom_buffering(int(sample, 16))
    
    #print(len(DMEM_VALUES[0:256]))
    #print(len(DMEM_VALUES[256:512]))
    #coe_generator_misc(DMEM_VALUES[0:256])
    #coe_generator_misc(DMEM_VALUES[256:512])
    #print(HASHED_INDICES)
    coe_generator(HASHED_INDICES)

            

if __name__ == "__main__":
    main()