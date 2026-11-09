# SNIP — Safe Network Intrusion Protection

SNIP is a pipelined, multi-core, quad-threaded RISC-V network processor with an
FPGA-based Bloom filter, mapped onto a NetFPGA-1G board. It was built to accelerate
the [SNORT](https://www.snort.org/) network intrusion detection software by
pre-screening packet payloads in hardware, reaching approximately **8 Gbps**.
The design was demonstrated protecting a network against malicious traffic such
as the WannaCry malware while approaching line rate.

The system combines a hardware Bloom filter for fast pattern pre-matching with
two 64-bit RISC-V cores that confirm matches in software. Only packets flagged by
the Bloom filter are handed to the processors, so the cores stay off the critical
path for the vast majority of traffic.

> **Board support:** this design targets the **NetFPGA-1G** (Xilinx Virtex-II Pro
> 50, `xc2vp50ff1152`) using the NetFPGA 2.2 reference-router flow. All checked-in
> bitstreams were built from `nf2_top_par.ncd` for `2vp50ff1152`. It has not been
> validated on other FPGA boards.

## Architecture

```
 NetFPGA reference datapath
 ┌────────────┐   ┌──────────────────┐   ┌──────────────┐   ┌───────────────┐
 │ input      │──▶│ output port      │──▶│ user_data_   │──▶│ output queues │──▶
 │ arbiter    │   │ lookup           │   │ path (SNIP)  │   │               │
 └────────────┘   └──────────────────┘   └──────┬───────┘   └───────────────┘
                                                │
                        ┌───────────────────────┴────────────────────────┐
                        │                 datapath_deter                 │
                        │                                                │
   packet ─────────────▶│  header strip ──▶ 8× sliding 8-byte windows   │
                        │                        │                       │
                        │                        ▼                       │
                        │              ┌──────────────────┐              │
                        │              │  Bloom filter    │              │
                        │              │ 4 hashes / 2×64K │              │
                        │              └────────┬─────────┘              │
                        │                       │ match                  │
                        │                       ▼                        │
                        │              ┌──────────────────┐              │
                        │              │  core_manager    │              │
                        │              └───┬──────────┬───┘              │
                        │                  ▼          ▼                  │
                        │           ┌──────────┐ ┌──────────┐            │
                        │           │ RISC-V   │ │ RISC-V   │            │
                        │           │ core 1   │ │ core 2   │            │
                        │           │ 4 threads│ │ 4 threads│            │
                        │           └──────────┘ └──────────┘            │
                        │                                                │
                        │  special_fifo ──▶ packet forwarding/drop       │
                        └────────────────────────────────────────────────┘
```

### RISC-V core

A five-stage pipeline (IF / ID / EX / MEM / WB) implementing a subset of the 64-bit RISC-V
ISA. Each core is **quad-threaded**: four independent program counters are
multiplexed through the pipeline, and the register file provides 32 registers
per thread (128 × 64-bit entries). Instruction and data memories are generated
Xilinx block-RAM IP cores.

| File | Purpose |
| --- | --- |
| `Project/Modules/datapath.v` | Five-stage processor datapath and pipeline registers |
| `Project/Modules/control_unit.v` | Instruction decode / control-signal generation |
| `Project/Modules/ALU_64.v` | 64-bit ALU |
| `Project/Modules/RegFile.v` | Behavioural register file |
| `Project/Modules/pcCounter.v` | Quad-threaded program counter / thread scheduler |
| `Project/Modules/pipe_reg_*.v` | IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers |

### Bloom filter

SNIP uses a Bloom filter as a parallel pre-filter: it can cheaply prove that an
8-byte payload window is *not* one of the known malicious patterns. A Bloom
filter has **no false negatives**; it can produce false positives, which the
RISC-V cores then resolve with an exact match by searching their local data
memory for the candidate 64-bit `matched_data` word.

#### Bit array and hashes

Each `bloom_filter` instance owns two 64K × 1 dual-port block RAMs
(`bloom_buffer`), configured as read-only ROMs initialized with the **same**
65,536-bit vector from `Project/IpCores/bloom.coe`. Replicating the 64K-bit table
across two dual-port BRAMs provides **four simultaneous read ports** per filter
instance (2 × 65,536 = 131,072 bits / 16 KiB of physical BRAM per filter, or
1 Mbit / 128 KiB across all eight parallel filters).

Each 64-bit window is hashed four ways. The 16-bit results index the four BRAM
ports in parallel:

| Lookup | Module | Index | BRAM port |
| --- | --- | --- | --- |
| 0 | `mod_hash` | `data[15:0]` (i.e. `data % 65536`) | buffer 0, port A |
| 1 | `shift_hash` | `(data[31:0] << 1)[15:0]` | buffer 0, port B |
| 2 | `murmur_hash` (low word) | `(data[15:0] ^ data[31:16]) + 1` | buffer 1, port A |
| 3 | `murmur_hash` (high word) | `(data[47:32] ^ data[63:48]) + 1` | buffer 1, port B |

`murmur_hash` is a single-cycle folded-XOR variant (the full MurmurHash3 mixing
sequence is left in the module header comment for reference), keeping all four
hash paths purely combinational with zero DSP/multiplier overhead.

Because each BRAM provides two independent read ports, all four lookups complete
in one clock. A window matches only if all four bits are set:

```verilog
assign match = bloom_value_0 & bloom_value_1 & bloom_value_2 & bloom_value_3;
```

#### Sliding-window scan

The packet path builds a 120-bit sliding register from the current and previous
64-bit words:

```verilog
assign packet = {in_fifo_data[55:0], in_data_p[63:0]};
```

Eight `bloom_filter` instances hash overlapping 8-byte windows at bit offsets
0, 8, 16, ..., 56 (byte offsets 0 through 7). Together they cover every byte
alignment of an 8-byte pattern within the 15-byte window, so a pattern is found
no matter where it starts in the 64-bit stream. All eight filters evaluate in
parallel, once per clock. At the NetFPGA-1G's 125 MHz clock this scans one 64-bit
word per cycle, i.e. 8 bytes × 125 MHz = 1 GB/s = **8 Gbps**.

The BRAM read is synchronous, so `match` is valid one cycle after a window is
presented. `prev_data` delays the input word by one cycle so `matched_data` stays
aligned with the word that produced the match:

```verilog
always @(posedge clk)
    prev_data <= in_data;

assign matched_data = match ? prev_data : 64'b0;
```

#### Loading patterns

The filter is static — there is no runtime write port. Patterns are inserted
offline: each 8-byte ASCII pattern is hashed with all four functions and the
resulting bit positions are OR'd into a single 65,536-bit vector in `bloom.coe`.
The generators live in `archive/Bloom Filter/Scripts/` (e.g.
`bloom_initialize.py`) and `archive/Scripts/`. The checked-in image has 68 set
bits in its 65,536-bit table (~0.1% occupancy), and both BRAMs in every filter
instance load this same `.coe` file. To change the pattern set, regenerate the
`.coe`, update the `coe_file` path in `bloom_buffer.xco`, and rebuild the BRAM.

> False positives are possible when all four bits happen to be set by other
> patterns, but a pattern that was inserted can never be missed. `core_manager`
> forwards every candidate to a RISC-V core for the exact check.

| File | Purpose |
| --- | --- |
| `Project/Modules/bloom_filter.v` | Top-level Bloom filter with four hashes |
| `Project/Modules/*_hash.v` | Hash function implementations |
| `Project/IpCores/bloom_buffer.v/.xco` | 64K × 1 dual-port Bloom buffer |
| `Project/IpCores/bloom.coe` | Initial Bloom filter contents |

### Packet path and core management

`Project/Modules/datapath_deter.v` implements the NetFPGA user data path. It
strips packet headers, runs the Bloom filters over the payload, buffers the
packet in `special_fifo`, and uses `core_manager.v` to dispatch matched payloads
to whichever core is free. A match counter and the software registers are exposed
through the NetFPGA register interface (`Project/Fedora/datapath.xml`).

## Repository layout

```
Project/                  Main SNIP hardware design
├── Modules/              Verilog RTL (processor, Bloom filter, packet path)
├── IpCores/              Xilinx IP cores and .coe memory initialisation
├── Fedora/               NetFPGA/Fedora register-system XML
├── Bitfiles/             Prebuilt FPGA bitstreams from development runs
└── script/datapathReg    Perl helper for reading/writing SNIP registers

archive/                  Historical lab work and non-main development code
├── Lab7/ … Lab11/        Course lab submissions building up the processor
├── Lab10_fedora/         Fedora build of Lab 10
├── lab5_mini_ids_src/    Early mini-IDS source (NetFPGA 2.2)
├── Bloom Filter/         Standalone Bloom filter development and testbenches
├── Code/                 RISC-V assembly / bubble-sort test programs
├── Scripts/              Bloom .coe generators, hashing, assembler scripts
└── ALU_64.v              Early standalone ALU copy
```

## Building

The design follows the NetFPGA 2.2 reference-router flow:

1. **Toolchain** — Xilinx ISE (the included cores were generated with ISE 10.1),
   targeting the Virtex-II Pro 50 (`xc2vp50`) on the NetFPGA-1G, plus the
   NetFPGA 2.2 reference router package on a Linux/Fedora host.
2. **Integrate the RTL** — place the modules from `Project/Modules/` into the
   reference design's user data path and add the IP cores from `Project/IpCores/`.
3. **Register system** — use the XML in `Project/Fedora/` with Fedora to generate
   the register decode logic. The generated register addresses are consumed by
   `Project/script/datapathReg`.
4. **Synthesise and place-and-route** — run the NetFPGA `make` flow in the synth
   directory. Regenerate any IP core from its `.xco` file if the project paths
   differ.
5. **Program the board** — download one of the bitstreams in `Project/Bitfiles/`
   with the standard NetFPGA programming tools, or use a bitstream produced by
   step 4. All checked-in bitstreams target `2vp50ff1152` (NetFPGA-1G).

## Configuring and running

`Project/script/datapathReg` is a small Perl helper (it expects the NetFPGA Perl
libraries under `/usr/local/netfpga/lib/Perl5`) that talks to the design through
the `regwrite` / `regread` utilities:

```sh
./datapathReg reset              # reset the processor
./datapathReg pattern <string>   # load an ASCII match pattern
./datapathReg dmem_c1 <index>    # read core 1 data memory
./datapathReg dmemW_c1 <index> <hi> <lo>   # write core 1 data memory
./datapathReg allmem_c1          # dump core 1 data memory
./datapathReg allregs            # show key registers
```

### Register map

| Address | Register | Type | Description |
| --- | --- | --- | --- |
| `0x2000300` | `pattern_high` | SW | Upper 32 bits of the match pattern |
| `0x2000304` | `pattern_low` | SW | Lower 32 bits of the match pattern |
| `0x2000308` | `ids_cmd` | SW | Control: bit 0 resets PC, bit 1 core 1 dMem write, bit 2 core 2 dMem write |
| `0x200030c` | `dmem_index_c1` | SW | Core 1 data-memory index |
| `0x2000310` | `dmem_data_high_c1` | SW | Core 1 data-memory write data (upper) |
| `0x2000314` | `dmem_data_low_c1` | SW | Core 1 data-memory write data (lower) |
| `0x2000318` | `dmem_index_c2` | SW | Core 2 data-memory index |
| `0x200031c` | `dmem_data_high_c2` | SW | Core 2 data-memory write data (upper) |
| `0x2000320` | `dmem_data_low_c2` | SW | Core 2 data-memory write data (lower) |
| `0x2000324` | `matches` | HW | Match counter |
| `0x2000328` | `dmem_value_high_c1` | HW | Core 1 data-memory read data (upper) |
| `0x200032c` | `dmem_value_low_c1` | HW | Core 1 data-memory read data (lower) |
| `0x2000330` | `dmem_value_high_c2` | HW | Core 2 data-memory read data (upper) |
| `0x2000334` | `dmem_value_low_c2` | HW | Core 2 data-memory read data (lower) |

## Notes and limitations

- The prebuilt `.bit` files in `Project/Bitfiles/` are development snapshots;
  several correspond to intermediate FIFO/matcher/Bloom experiments. They are the
  source of truth for the target: all are built from `nf2_top_par.ncd` for
  `2vp50ff1152` (Virtex-II Pro 50, NetFPGA-1G).
- The Bloom filter is a probabilistic pre-filter. The RISC-V cores perform the
  definitive match, so false positives cost cycles but do not produce false
  reports.
- Memory contents are defined by the `.coe` files in `Project/IpCores/`. Update
  them (and regenerate the cores) to change the program or initial data.
- The archived lab directories are kept for reference and not part of the final build.

## History

SNIP was developed as a graduate course project (EE533). The repository history retains the incremental lab work that led to the final design.
