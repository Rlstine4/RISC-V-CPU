import sys
import nltk

I_type = ['addi', 'slti', 'sltiu', 'xori', 'andi', 'ori']
R_type = ['add', 'and', 'or', 'sll', 'slt', 'sltu', 'sra', 'srl', 'sub', 'xor']

#TODO: Add more OPCODE constants and add more lists for the other instruction types

OPCODE_I_TYPE = '0010011'
OPCODE_R_TYPE = '0110011'

file_name = sys.argv[1]

with open(file_name, 'r') as file:

   for line in file:
    words = nltk.word_tokenize(line)

    if '' in words:
        words.remove('')
    
    print(words)