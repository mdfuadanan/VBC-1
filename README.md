# VBC-1 (Very Basic Computer 1)

[![VHDL](https://img.shields.io/badge/Language-VHDL-00599C.svg)](https://en.wikipedia.org/wiki/VHDL)
[![FPGA](https://img.shields.io/badge/Target%20FPGA-Gowin%20GW1NZ--1-orange.svg)](https://www.gowinsemi.com/)
[![Toolchain](https://img.shields.io/badge/EDA-Gowin%20V1.9.11-blue.svg)](https://www.gowinsemi.com/)
[![Simulation](https://img.shields.io/badge/Waveform-GTKWave-green.svg)](http://gtkwave.sourceforge.net/)
[![Status](https://img.shields.io/badge/Status-Tested%20%26%20Synthesized-brightgreen.svg)]()

**VBC-1** is a lightweight, educational 4-bit microprocessor architecture implemented in synthesizable VHDL. Designed for FPGA synthesis on the Gowin GW1NZ-1 (Tang Nano 1K), the processor features a custom 8-bit instruction set, dual general-purpose registers, an arithmetic logic unit (ALU), a relative/loadable program counter (RPC), and integrated peripherals including 7-segment display decoding, push-button de-bouncing, and LED I/O.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Key Specifications](#key-specifications)
- [Block Diagram](#block-diagram)
- [Instruction Set Architecture (ISA)](#instruction-set-architecture-isa)
- [Built-In Demo Program](#built-in-demo-program)
- [Hardware Pin Mapping (Gowin GW1NZ-1)](#hardware-pin-mapping-gowin-gw1nz-1)
- [Project File Structure](#project-file-structure)
- [Toolchain & Building](#toolchain--building)
- [Simulation & Waveforms](#simulation--waveforms)
- [Running on FPGA](#running-on-fpga)

---

## Architecture Overview

The VBC-1 architecture is structured into modular RTL components:

1. **Instruction Memory (`16_Byte_Instruction_Memory.vhd`)**: 16-byte ROM/RAM holding 8-bit instruction words addressed by a 4-bit PC.
2. **Instruction Decoder (`VBC1_Instruction_Decoder.vhd`)**: Decodes 3-bit opcodes and operand selectors, evaluates zero flags (`Z0`, `Z1`), and drives datapath multiplexer controls (`M1`–`M6`) and register load enables.
3. **Data Path (`VBC1_Data_Path.vhd`)**: Contains two 4-bit general-purpose registers (`R0`, `R1`), an output register (`OP`), routing multiplexers, and the ALU.
4. **ALU (`VBC1_ALU.vhd`)**: Performs immediate loads, addition (`ADD`, `ADDI`), and 1-bit right shift (`SR0`).
5. **Program Counter (`VBC1_RPC.vhd`)**: 4-bit program address generator supporting sequential execution ($PC + 1$) and conditional branch targets.
6. **I/O Subsystem (`VBC1_IO_Module.vhd`)**: Handles 4-bit switch input buffering, LED output register drivers, and 7-segment hex display decoding.
7. **Board Top Wrapper (`VBC1_Neg_Borad_Top.vhd`)**: Integrates button synchronization/single-pulse generator (`One_Pulse_Button.vhd`) for hardware single-stepping and inverts active-low signals for physical FPGA buttons and displays.

---

## Key Specifications

| Parameter | Specification |
| :--- | :--- |
| **Datapath Width** | 4-bit |
| **Instruction Width** | 8-bit (`IR[7:5]` Opcode, `IR[4:3]` Register Selectors, `IR[3:0]` Immediate/Address) |
| **Address Bus Width** | 4-bit (16 memory locations) |
| **General Purpose Registers** | 2 registers (`R0`, `R1`, 4-bit each) |
| **Output Register** | 1 dedicated 4-bit register (`OP`) |
| **Instruction Memory** | $16 \times 8\text{-bit}$ synchronous RAM/ROM |
| **Flags** | Zero detection flags (`Z0` for R0, `Z1` for R1) |
| **Target Device** | Gowin GW1NZ-LV1QN48C6/I5 (Tang Nano 1K / GW1NZ-1) |
| **Clocking Modes** | Hardware single-pulse step button & high-frequency onboard oscillator |

---

## Block Diagram

```
flowchart TB
    subgraph Control_Unit [Control & Sequencing]
        RPC["Program Counter (VBC1_RPC)<br/>prog_a[3:0]"]
        MEM["Instruction Memory (16 Bytes)<br/>16 x 8-bit"]
        DEC["Instruction Decoder<br/>Control Signals M1..M6, Load Enables"]
    end

    subgraph Data_Path [VBC-1 Datapath]
        M4["MUX4 (R0/R1)"]
        M5["MUX5 (Reg / Imm)"]
        M2["MUX2 (R0/R1)"]
        ALU["ALU (ADD, ADDI, SHIFT, LOADI)"]
        M3["MUX3 (ALU / Reg)"]
        M1["MUX1 (ALU / DI)"]
        R0["Register R0 (4-bit)"]
        R1["Register R1 (4-bit)"]
        OP_REG["Output Register OP (4-bit)"]
    end

    subgraph IO_Module [Peripherals & I/O]
        SW_IN["4-bit Switches (SW)"]
        LED_OUT["8-bit LEDs (IO + OP)"]
        SEG_OUT["7-Segment Display (Seg[6:0])"]
        BTN_SYNC["One-Pulse Debouncer (CLK Step)"]
    end

    RPC -->|pc_addr| MEM
    MEM -->|IR[7:0]| DEC
    MEM -->|IR[3:0]| M5
    MEM -->|IR[7:5]| ALU

    DEC -->|M1..M5, Load_R0, Load_R1, Load_OP| Data_Path
    DEC -->|M6 (Jump Load)| RPC

    R0 -->|Z0 Detection| DEC
    R1 -->|Z1 Detection| DEC

    SW_IN -->|di| M1
    M1 --> R0 & R1
    R0 & R1 --> M2 & M4
    M4 --> M5
    M2 --> ALU
    M5 --> ALU
    ALU --> M3
    M2 --> M3
    M3 --> M1

    M2 --> OP_REG
    OP_REG --> LED_OUT
    SW_IN --> SEG_OUT
    BTN_SYNC -->|Single Pulse CLK| RPC & Data_Path
```

---

## Instruction Set Architecture (ISA)

The processor executes 8 instructions encoded in an 8-bit instruction format:
- `IR(7 downto 5)`: 3-bit Opcode
- `IR(4)`: Destination Register (`0` = `R0`, `1` = `R1`)
- `IR(3)`: Source Register (`0` = `R0`, `1` = `R1`) (for 2-register ops)
- `IR(3 downto 0)`: 4-bit Immediate constant or target jump address

| Opcode `IR[7:5]` | Mnemonic | Syntax | Description | Machine Code Format | Example |
| :---: | :--- | :--- | :--- | :---: | :--- |
| `000` | **MOV** | `MOV DR, SR` | Copy contents of `SR` into `DR` | `000 D S 000` | `MOV R1, R0` (`0x10`) |
| `001` | **LOADI** | `LOADI DR, Imm` | Load 4-bit immediate data into `DR` | `001 D [Imm]` | `LOADI R0, 3` (`0x23`) |
| `010` | **ADD** | `ADD DR, SR` | $DR \leftarrow DR + SR$ | `010 D S 000` | `ADD R1, R0` (`0x50`) |
| `011` | **ADDI** | `ADDI DR, Imm` | $DR \leftarrow DR + Imm$ | `011 D [Imm]` | `ADDI R1, 3` (`0x73`) |
| `100` | **SHIFT** | `SHIFT DR, SR` | Shift right 1-bit (`0 & SR[3:1]`) into `DR` | `100 D S 000` | `SHIFT R1, R0` (`0x90`) |
| `101` | **IN** | `IN DR` | Load external 4-bit switch data into `DR` | `101 D 0000` | `IN R1` (`0xB0`) |
| `110` | **OUT** | `OUT SR` | Output `SR` value to `OP` register / LEDs | `110 S 0000` | `OUT R0` (`0xC0`) |
| `111` | **JNZ** | `JNZ DR, Addr` | Jump to `Addr` if `DR != 0` | `111 D [Addr]` | `JNZ R1, 0x0` (`0xF0`) |

---

## Built-In Demo Program

The ROM in [`src/16_Byte_Instruction_Memory.vhd`](src/16_Byte_Instruction_Memory.vhd) comes pre-loaded with a verification program testing arithmetic, shift, I/O, and branching:

```text
Addr | Binary Code | Hex  | Assembly         | Description
-----+-------------+------+------------------+-------------------------------------
 0   | 1011 0000   | 0xB0 | IN R1            | Read 4-bit DIP switches into R1
 1   | 1101 0000   | 0xD0 | OUT R1           | Output R1 to LED output register
 2   | 0010 0011   | 0x23 | LOADI R0, 3      | Load immediate 3 into R0
 3   | 1100 0000   | 0xC0 | OUT R0           | Output R0 to LED output register
 4   | 0001 0000   | 0x10 | MOV R1, R0       | Copy R0 (3) into R1
 5   | 1100 0000   | 0xC0 | OUT R0           | Output R0
 6   | 0010 0101   | 0x25 | LOADI R0, 5      | Load immediate 5 into R0
 7   | 0101 0000   | 0x50 | ADD R1, R0       | Add R0 to R1 (R1 = 3 + 5 = 8)
 8   | 1100 0000   | 0xC0 | OUT R0           | Output R0
 9   | 0111 0011   | 0x73 | ADDI R1, 3       | Add immediate 3 to R1 (R1 = 8 + 3 = 11)
 10  | 1101 0000   | 0xD0 | OUT R1           | Output R1 (0xB)
 11  | 1001 0000   | 0x90 | SHIFT R1, R0     | Shift R0 right by 1 -> store in R1 (5 >> 1 = 2)
 12  | 1101 0000   | 0xD0 | OUT R1           | Output R1 (0x2)
 13  | 1111 0000   | 0xF0 | JNZ R1, 0x0      | Jump to Addr 0 if R1 != 0 (Loop back)
 14  | 0000 0000   | 0x00 | NOP              | Halt / NOP
 15  | 0000 0000   | 0x00 | NOP              | Halt / NOP
```

---

## Hardware Pin Mapping (Gowin GW1NZ-1)

Physical constraints configured in [`src/VBC-1.cst`](src/VBC-1.cst) for the **GW1NZ-LV1QN48C6/I5**:

| Port Name | Direction | Pin Number | IO Type | Description |
| :--- | :---: | :---: | :---: | :--- |
| `CLK_Nano` | Input | `47` | LVCMOS33 | On-board master oscillator clock |
| `CLK` | Input | `17` | LVCMOS33 | Manual step push-button (active-low) |
| `RST` | Input | `18` | LVCMOS33 | System reset push-button (active-low) |
| `SW[0]` | Input | `28` | LVCMOS33 | Data switch bit 0 |
| `SW[1]` | Input | `27` | LVCMOS33 | Data switch bit 1 |
| `SW[2]` | Input | `15` | LVCMOS33 | Data switch bit 2 |
| `SW[3]` | Input | `16` | LVCMOS33 | Data switch bit 3 |
| `LED[0..3]` | Output | `24, 10, 9, 11` | LVCMOS33 | I/O Module Data / Status LEDs |
| `LED[4..7]` | Output | `31, 30, 29, 19`| LVCMOS33 | ALU / OP Register Output LEDs |
| `Seg[0..6]` | Output | `40, 41, 38, 39, 35, 34, 20` | LVCMOS33 | 7-Segment Display (Segments A to G) |

---

## Project File Structure

```text
VBC-1/
├── VBC-1.gprj                  # Gowin FPGA Project file
├── VBC-1.gprj.user             # Gowin User Settings
├── README.md                   # Project documentation
├── src/                        # VHDL RTL & Simulation sources
│   ├── 16_Byte_Instruction_Memory.vhd  # 16-byte instruction ROM/RAM
│   ├── 2_to_1_MUX.vhd                  # 4-bit 2-to-1 Multiplexer
│   ├── 4_bit_loadable_register.vhd     # 4-bit synchronous load register
│   ├── One_Pulse_Button.vhd            # Synchronizer & single-pulse generator
│   ├── VBC1_ALU.vhd                    # Arithmetic & Logic Unit
│   ├── VBC1_Borad_Top.vhd              # Standard board top-level wrapper
│   ├── VBC1_Data_Path.vhd              # Datapath connecting ALU, MUXes, and Regs
│   ├── VBC1_IO_Module.vhd              # Switch input buffer & 7-seg decoder
│   ├── VBC1_Instruction_Decoder.vhd    # Instruction decoding & control logic
│   ├── VBC1_Neg_Borad_Top.vhd          # Active-low board top wrapper with debouncer
│   ├── VBC1_RPC.vhd                    # Relative/loadable Program Counter
│   ├── VBC1_Top.vhd                    # Core top-level integration
│   ├── VBC-1.cst                       # Gowin physical pin constraint file
│   ├── Wave_out_put_of_VBC1_Top.gtkw   # GTKWave view config (Core top)
│   ├── Wave_out_put_of_VBC1_Board_Top.gtkw # GTKWave view config (Board top)
│   ├── tb_VBC1_Top.vhd                 # Testbench for core top
│   ├── tb_VBC1_Board_Top.vhd           # Testbench for board top
│   ├── tb_VBC1_Data_Path.vhd           # Unit testbench for datapath
│   └── tb_VBC1_Instuction_Decoder.vhd  # Unit testbench for instruction decoder
└── impl/                       # Gowin synthesis and PnR output bitstreams
    ├── gwsynthesis/            # Synthesis netlists and reports
    └── pnr/                    # Place & Route bitstream (VBC-1.fs)
```

---

## Toolchain & Building

### Prerequisites

- **Gowin EDA** (V1.9.9+ or V1.9.11 Education/Standard edition)
- **Gowin Programmer** (for flashing bitstream `.fs` over USB-JTAG)
- *(Optional for simulation)*: **GHDL**, **ModelSim/QuestaSim**, and **GTKWave**

### Building with Gowin EDA

1. Open **Gowin EDA**.
2. Click **File -> Open Project** and select `VBC-1.gprj`.
3. Ensure `VBC1_Neg_Borad_Top.vhd` (or `VBC1_Board_Top.vhd`) is set as the Top Module.
4. Run **Synthesize** (Synthesize RTL to netlist).
5. Run **Place & Route** to generate the bitstream `impl/pnr/VBC-1.fs`.
6. Open **Gowin Programmer**, detect the cable, and program `VBC-1.fs` into SRAM or internal Flash.

---

## Simulation & Waveforms

You can simulate the processor using GHDL or any VHDL-2008 compliant simulator:

### Simulating with GHDL

```bash
# Analyze all VHDL source files
ghdl -a --std=08 src/*.vhd

# Elaborate top-level testbench
ghdl -e --std=08 VBC1_Top_tb

# Run simulation and dump waveforms to VCD
ghdl -r --std=08 VBC1_Top_tb --vcd=vbc1_sim.vcd

# View signals in GTKWave
gtkwave vbc1_sim.vcd src/Wave_out_put_of_VBC1_Top.gtkw
```

Pre-configured GTKWave `.gtkw` workspace files are provided in `src/` to instantly inspect control lines (`M1`–`M6`), register values (`R0`, `R1`, `OP`), memory address, instruction register (`IR`), and I/O signals.

---

## Running on FPGA

1. Set the 4-bit DIP switches (`SW[3:0]`) to an initial test value (e.g., `0001`).
2. Press the **Reset Button** (`RST` - Pin 18) to initialize the PC and internal registers to zero.
3. Press the **Clock Step Button** (`CLK` - Pin 17) to single-step execution cycle-by-cycle.
4. Observe the results on:
   - **`LED[7:4]`**: Displays the 4-bit output register (`OP`).
   - **`LED[3:0]`**: Displays the input/peripheral status register (`IO`).
   - **7-Segment Display**: Shows the decoded hex digit of the current operand/result.

---

## License

This project is licensed under the [MIT License](LICENSE) — feel free to use, modify, and distribute for educational and hardware design projects.
