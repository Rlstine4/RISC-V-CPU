bit_lengths = [32, 1, 1, 1, 5, 4, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 4, 64, 5, 1, 1, 1, 1, 1, 1, 5, 64]
string_list = ["id_inst                 :", "id_stall                :", "id_jump                 ;", "branch_flag             :", "id_rd                   :", "id_alu_op               :", "id_alu_src              :", "id_branch               :",
                "id_mem_read             :", "id_mem_write            :", "id_reg_write            :", "id_mem_to_reg           :", "ex_alu_op               :", "ex_alu_src              :",
                "ex_branch               :", "ex_mem_read             :", "ex_mem_write            :", "ex_reg_write            :", "ex_mem_to_reg           :", "ex_rd                   :", "ex_alu_out              :",
                "mem_rd                  :", "mem_read                :", "mem_write               :", "mem_reg_write		:", "mem_mem_to_reg          :", "wb_RegWrite             :", "wb_mem_to_reg           :",
                "wb_rd                   :", "wb_mem_out              :"]

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
    for i in range(len(res)):
        if i%30 == 0:
            out.write("\n" + "\n" + "\n")
        else:
            out.write(string_list[i] + "   " + res[i] + "\n")