#DEPTH = int(input("Please enter Block RAM depth: "))
DEPTH = 65536
WIDTH = int(input("Please enter Block RAM width: "))
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


INITIAL_VECTOR = [0] * DEPTH

INITIAL_VECTOR[69] = 1
INITIAL_VECTOR[138] = 1
INITIAL_VECTOR[225] = 1
INITIAL_VECTOR[642] = 1

INITIAL_VECTOR[326] = 1
INITIAL_VECTOR[652] = 1
INITIAL_VECTOR[803] = 1
INITIAL_VECTOR[668] = 1

INITIAL_VECTOR[843] = 1
INITIAL_VECTOR[662] = 1
INITIAL_VECTOR[303] = 1
INITIAL_VECTOR[994] = 1


with open(FILENAME, "w") as file:
    file.write("; Sample memory initialization file for Single Port Block Memory, \n")
    file.write("; v3.0 or later.\n")
    file.write(";\n")
    file.write("; This .COE file specifies initialization values for a block \n")
    file.write("; memory of depth=" + str(DEPTH) +", and width=" + str(WIDTH) + ". In this case, values are " + "\n")
    file.write("; specified in " + FORMAT + " format" + "\n") # CHANGE THIS TO ACCOUNT FOR HEX
    file.write("memory_initialization_radix=" + str(RADIX) + ";" + "\n")
    file.write("memory_initialization_vector=" + "\n")

    for idx, value in enumerate(INITIAL_VECTOR):

        if (idx != 0) and( idx % 20) == 0:
            file.write("\n")

        if idx == len(INITIAL_VECTOR) - 1:
            file.write(str(value) + ";")
        
        else:
            file.write(str(value) + ", ")



        
    



