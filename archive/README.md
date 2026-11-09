# Archive

This directory holds historical lab work, early prototypes, and development
scripts that are **not** part of the main SNIP build. The production design lives
in [`../Project`](../Project); see the [root README](../README.md) for the
architecture and build flow.

| Directory / file | Contents |
| --- | --- |
| `Lab7/` | NetFPGA IDS passthrough lab, DeterLab topology, lab report, bitstreams |
| `Lab8/` | Pipelined RISC-V datapath lab (IF/ID/EX/MEM/WB), testbenches, bitstream |
| `Lab9/` | Pipelined datapath with logic analyser and control unit |
| `Lab10/` | Pipelined processor with FIFO support, IP cores, testbenches |
| `Lab10_fedora/` | Fedora-packaged build of the Lab 10 design |
| `Lab11/` | Multithreaded FIFO / quad-thread processor work and bitstreams |
| `lab5_mini_ids_src/` | Early mini-IDS source for the NetFPGA 2.2 reference router |
| `Bloom Filter/` | Standalone Bloom filter development: hash experiments (CRC, Knuth, XOR, Murmur, shift, mod), testbenches, `.coe` generators |
| `Code/` | RISC-V assembly and machine-code test programs (bubble sort) |
| `Scripts/` | Bloom `.coe` generators, hash utilities, RISC-V assembler, logic-analyser helpers |
| `ALU_64.v` | Early standalone copy of the 64-bit ALU |

## Notes

- Paths inside these directories (Xilinx `.xco` files, scripts) may still point to
  the original authoring machines and course lab layout.
- The lab directories are preserved as-is for provenance; they are not expected
  to build without the matching course/NetFPGA environment.
- `Lab10_fedora/Lab10.bit` and the `Lab11/*.bit` files are lab-era bitstreams,
  not the final SNIP image. Final/intermediate SNIP bitstreams are in
  `../Project/Bitfiles/`.
