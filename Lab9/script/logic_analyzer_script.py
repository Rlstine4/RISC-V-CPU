bit_lengths = [32, 1, 1, 1, 5, 4, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 4, 64, 5, 1, 1, 1, 1, 1, 1, 5, 64]

file_path = r"analyzer_script_input.txt"
outfile_path = r"analyzer_script_output.txt"
f = open(file_path,'r')
out = open(outfile_path,'w')

list = f.read().splitlines()
for i in range(len(list)):
    h = list[i]
    bits = bin(int(h, 16))[2:].zfill(len(h) * 4)
    new_bits = bits[3:]
    stritr = iter(new_bits)
    res = ["".join(next(stritr) for idx in range(size)) for size in bit_lengths]
    for x in res:
        out.write(x + "\n")