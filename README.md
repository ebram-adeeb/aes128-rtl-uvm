# AES-128 UVM Verification Environment

A SystemVerilog/UVM testbench that verifies the AES-128 encryption datapath (`Encrypt_Top` / `aes_wrapper`) originally designed as part of the **NTI "Digital Design using FPGA"** training program. The DUTs outputs are self-checked in time against [kokke/tiny-AES-c](https://github.com/kokke/tiny-AES-c) a reference C implementation of AES wired in through SystemVerilog DPI-C.

> This repo verifies the **encryption-** datapath. The original RTL (including the decrypt path and CBC mode) lives at [Youssef-H23/AES_NTI](https://github.com/Youssef-H23/AES_NTI).

This UVM verification environment was built as the final project of **Eng. [Sherif Hosny](https://www.linkedin.com/in/sherif-hosny-0731b32b)s** UVM diploma.

## Table of Contents

- [Overview](#overview)

- [Repository Structure](#repository-structure)

- [Design Under Test](#design-under-test)

- [Verification Architecture](#verification-architecture)

- [Reference Model & Self-Checking](#reference-model--self-checking)

- [Test Sequences](#test-sequences)

- [Coverage](#coverage)

- [Running the Testbench](#running-the-testbench)

- [Verification Metrics](#verification-metrics)

- [Roadmap](#roadmap)

- [Acknowledgments](#acknowledgments)

- [License](#license)

## Overview

This project takes a designed AES-128 encryption core and wraps it in a class-based UVM environment to verify it the way an industry testbench would: constrained-random + directed stimulus, a golden-model scoreboard and functional coverage closure. Rather than the directed print-and-eyeball testing typical of an academic RTL project.

Highlights:

- **UVM 1.2** testbench (agent/driver/monitor/sequencer + sequencer) driving a clocking-block interface into the DUT

- **DPI-C golden reference model** (not a re-implementation in SystemVerilog). The scoreboard calls straight into a well-known, independently-verified AES-128 C library

- **NIST FIPS-197 Known-Answer Tests** plus constrained-random and corner-case stimulus orchestrated by a virtual sequence

- **Functional coverage** on every byte of the plaintext and key valid handshake toggling and reset transitions in addition to QuestaSim code coverage on the RTL

## Repository Structure

```

aes128-rtl-uvm/

├── AES_Encrypt_Only/       # DUT: AES-128 encryption-only RTL (Verilog)

│   ├── Encrypt_Top.v       # Top-level combinational 10-round AES-128 core

│   ├── aes_wrapper.v       # Clocked wrapper: registers I/O generates valid_out

│   ├── key_expansion.v

│   ├── key_scheduler.v

│   ├── sbox.v / subbytes.v

│   ├── ShiftRows.v

│   ├── col_mix.v / col_mix_single.v

│   ├── add_round_key.v / add_vector.v

│   ├── encrypt_round.v / encrypt_final_round.v

│   └── aes_params.vh

├── C-DPI/                  # Golden reference model (DPI-C)

│   ├── aes.c / aes.h       # kokke/AES-c. Unmodified reference AES implementation

│   └── aes_dpi.c           # dpi_aes_encrypt_ecb(). DPI-C bridge called by the scoreboard

├── UVM/                    # Verification environment (SystemVerilog / UVM)

│   ├── aes_interface.sv    # intf_aes. Driver & monitor clocking blocks

│   ├── my_sequence_item.svh

│   ├── my_sequences.svh    # aes_reset_seq, aes_kat_seq, aes_corner_case_seq aes_random_seq, aes_master_seq

│   ├── my_sequencer.svh / my_virtual_sequencer.svh

│   ├── my_driver.svh

│   ├── my_monitor.svh

│   ├── my_agent.svh

│   ├── my_subscriber.svh   # Functional coverage (cg_aes128_coverage)

│   ├── my_scoreboard.svh   # Self-checking against the DPI-C model

│   ├── my_environment.svh

│   ├── my_test.svh

│   ├── pack1.sv            # Package: imports UVM + includes all.svh files

│   └── top.sv               # Top-level testbench module

├── run.do                  # QuestaSim compile/elaborate/simulate/coverage script

└── README.md

```

## Design Under Test

`Encrypt_Top` is a unrolled, combinational 10-round AES-128 encryption core (key expansion → 9 standard rounds → 1 final round without MixColumns). `Aes_wrapper` adds the synchronous shell around it:

| Signal Direction | Width | Notes |

|---|---|---|---|

| `clk` | in | 1 | Free-running clock |

reset` | in | 1 | **Active-low** asynchronous |

| `valid_in` | in | 1 | Registers `plain_text`/`cipher_key` on the next edge |

| `plain_text` | in | 128 | |

| `cipher_key` | in | 128 |

| `cipher_text` | out | 128 | Valid two cycles after `valid_in` |

| `valid_out` | out | 1 | Pulses two cycles after `valid_in` |

## Verification Architecture

Standard UVM topology, connected through a virtual interface (`intf_aes`) with separate driver (`cb_drv`) and monitor (`cb_mon`) clocking blocks:

```

my_test

└── my_environment

├── my_virtual_sequencer

├── my_agent

│    ├── my_sequencer

│    ├── my_driver     ──drives──▶ intf_aes.cb_drv ──▶ DUT

│    └── my_monitor    ◀─samples── intf_aes.cb_mon ◀── DUT

├── my_scoreboard   (analysis_imp from monitor)

└── my_subscriber   (analysis_imp from monitor. Coverage)

```

`my_test` starts a single `aes_master_seq` virtual sequence on the virtual sequencer, which drives the entire test flow end to end.

## Reference Model & Self-Checking

Rather than modeling AES a time in SystemVerilog (and risking the same bug in both the DUT and the checker) the scoreboard calls out to a C reference implementation through DPI-C:

```systemverilog

import "DPI-C" function void dpi_aes_encrypt_ecb(

input  byte key[16]

input  byte plaintext[16]

output byte ciphertext[16]

);

```

`aes_dpi.c` wraps `AES_init_ctx()` / `AES_ECB_encrypt()` from **kokke/tiny-AES-c** an independent widely-used NIST-vector-verified AES implementation. So the checkers correctness doesn't depend on the same assumptions as the RTL. Each monitored transaction is converted from a 128-bit vector to a byte array passed to the model and the resulting ciphertext is compared bit-for-bit against the DUTs output; any mismatch raises a `uvm_error`.

## Test Sequences

All sequences are orchestrated by `aes_master_seq` which runs: **reset → KAT → reset → corner cases → reset → **.

| Sequence | Purpose Stimulus count |

|---|---|---|

| `aes_reset_seq` | Pulses the active-low reset; one instance per phase boundary | 3

| `aes_kat_seq` | NIST FIPS-197 Appendix B known-answer vector, plus an all-zero key/plaintext case | 2 |

| `aes_corner_case_seq` | 8 boundary patterns (`0x0` `0xFF…F` `0x55…5` `0xAA…A` `0xA5…5` `0x5A…A5` and two half-and-half patterns) × 8 repetitions, each with `cipher_key` randomized across the same 4 boundary values | 64 |

| `aes_random_seq` | Fully constrained-random plaintext/key pairs | 4,096 |

| **Total per regression** | | **4,165 transactions**

## Coverage

**Functional coverage** (`my_subscriber` / `cg_aes128_coverage`). 1 Covergroup, 35 coverpoints/crosses spanning:

- All 16 bytes of `plain_text` and all 16 bytes of `cipher_key` each with a full 0–255 bin set

- `valid_in` / `valid_out` toggle coverage

- `reset` transition coverage (0→1 and 1→0 bins)

- Cross coverage: `reset × valid_in` `reset × valid_out`

Latest run: **8,198 / 8,198 bins hit. 100.00%**.

**Code coverage** (QuestaSim via `run.do`): block, condition, expression, statement and FSM coverage (`cover=bcesf`) collected on the `AES_Encrypt_Only` RTL saved to `AES_top.ucdb`. Latest run on `Encrypt_Top`: branches 781/786 (99.36%) statements 797/801 (99.50%) **99.43% total**.

## Running the Testbench

Requires **Siemens QuestaSim** (or ModelSim with DPI-C support) and a C compiler on your `PATH`.

```bash

vsim -do run.do

```

`run.do` will: compile the RTL with code coverage, compile `C-DPI/*.c`. Link it via DPI compile the UVM sources with functional coverage enabled run the full regression at `UVM_VERBOSITY=UVM_HIGH` and emit:

- `simulation_transcript.log`. Full UVM log

- `AES_top.ucdb`. Coverage database

- `SFC_cov_rprt.txt`. Code coverage report

## Verification Metrics

- **Functional coverage: 100.00%** (8,198 / 8,198 bins across 35 coverpoints/crosses)

- **Code coverage: 99.43%** total on `Encrypt_Top` (branches 99.36% statements 99.50%)

- **Scoreboard: 4,164 / 4,164 transactions checked, 0 mismatches**, against the DPI-C model

- 4,165 items driven per regression (3 reset + 2 KAT + 64 corner-case + 4,096 random)

- KAT status: NIST FIPS-197 Appendix B vector. **Pass**

- Regression result: `ERRORS=0 FATALS=0 WARNINGS=0`

## Roadmap

- [ ] **Monte Carlo Test (MCT)** sequence per NIST SP 800-38A chaining output back into the next plaintext input (in progress)

- [ ] Verify the decrypt path and CBC mode from the RTL, not just single-block ECB encryption

- [ ] SVA assertions on the `valid_in`/`valid_out` handshake and reset behavior, bound directly to the interface

- [ ] Close the remaining code-coverage gaps on `Encrypt_Top` (5 branch misses 4 statement misses). Likely unreachable/defensive logic, worth confirming with a waiver or a directed sequence


## Acknowledgments

- **Eng. [Sherif Hosny](https://www.linkedin.com/in/sherif-hosny-0731b32b)**. Instructor of the UVM diploma this verification environment was built for as the project

- **[kokke](https://github.com/kokke)**. Author of [tiny-AES-c](https://github.com/kokke/tiny-AES-c) used unmodified as the DPI-C golden reference model

- My teammates on the original RTL design (from the separate NTI "Digital Design using FPGA" training). See [Youssef-H23/AES_NTI](https://github.com/Youssef-H23/AES_NTI) for the full project and contributor list

