DATA_IN = int(input ('Input value you would like to hash: '))
DEPTH   = int(input ('Input depth of bloom buffer: '))

print("BEFORE: " + bin(DATA_IN))
DATA_IN = DATA_IN & 0xFFFFFFFFFFFFFFFF # Change to unsigned
print("AFTER: " + bin(DATA_IN))


LOW_DATA    = DATA_IN & 0x000000000000FFFF
KNUTH_DATA  = DATA_IN & 0x00000000FFFF0000
INVERT_DATA = DATA_IN & 0x0000FFFF00000000
HIGH_DATA   = DATA_IN & 0xFFFF000000000000


mod_hash =  LOW_DATA % DEPTH
knuth_hash = (KNUTH_DATA * (KNUTH_DATA + 3)) % DEPTH
#invert_hash = (INVERT_DATA ^ 0xFFFFFFFFFFFFFFFF) & 0x0000000000003FFF
xor_hash    = HIGH_DATA ^ LOW_DATA


print("Results of mod hash: " + bin(mod_hash) + " (" + str(mod_hash) + ")" + "\n")

print("Result of Knuth hash: " + bin(knuth_hash) + " (" + str(knuth_hash) + ")" + "\n")

#print("Result of Inverse hash: " + bin(invert_hash) + " (" + str(invert_hash) + ")"  + "\n") # BAD HASH

print("Result of XOR hash: " + bin(xor_hash) + " (" + str(xor_hash) + ")" + "\n")


bit_extractor = 0x00000000000003FF  # SHOULD BE CHANGED when needed (only works for 10 bits right now)

print("Mod idx: " + str(mod_hash & 0x00000000000003FF))
print("Knuth idx: " + str(knuth_hash & 0x00000000000003FF))
#print("Inverse idx: " + str(invert_hash))
print("XOR idx: " + str(xor_hash & 0x00000000000003FF))


#print("DATA_IN high bits: " + bin(DATA_IN_HIGH))
#print("DATA_IN low bits: " + bin(DATA_IN_LOW))

