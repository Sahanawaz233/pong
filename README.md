# FPGA VGA Pong Game

This repository contains the Verilog HDL source code for a complete, real-time Pong game designed for Xilinx FPGAs. It was specifically ported for the **Digilent Zybo Zynq-7000** board (125 MHz clock) but can also be adapted for the Arty S7 or other boards.

## Features
- Hardware VGA Controller (640x480 @ 60Hz)
- Game physics and collision detection
- Paddle controls via tactile buttons
- Synthesizable, purely combinational and sequential Verilog design

## File Structure
- `pong_top.v` - Top-level module connecting inputs, game engine, and VGA outputs
- `vga_sync.v` - Generates HSYNC, VSYNC, and Pixel Coordinates
- `clk_divider.v` - Divides the system clock to a 25 MHz pixel clock
- `game_logic.v` - Handles ball movement, bouncing, and paddle logic
- `tb_pong_top.v` / `tb_pong_image.v` - Testbenches for simulation

## Hardware Connections & Constraints (Zybo Rev B)
**Target FPGA Chip:** `xc7z010clg400-1`

- **System Clock**: `L16` (125 MHz)
- **Buttons (`btn[3:0]`)**:
  - `BTN0` (`R18`) - Player 1 Move Up
  - `BTN1` (`P16`) - Player 1 Move Down
  - `BTN2` (`V16`) - Player 2 Move Up
  - `BTN3` (`Y16`) - Player 2 Move Down
- **Switches (`sw[0]`)**:
  - `SW0` (`G15`) - Reset Game
- **VGA Output**: Built-in Zybo VGA port (16-bit color format RGB565)
  - **Red (`vga_r[4:0]`)**: `M19, L20, J20, G20, F19`
  - **Green (`vga_g[5:0]`)**: `H18, N20, L19, J19, H20, F20`
  - **Blue (`vga_b[4:0]`)**: `P20, M20, K19, J18, G19`
  - **Sync**: `P19` (HSYNC), `R19` (VSYNC)

## How to Run
1. Create a new RTL project in Xilinx Vivado.
2. Add all `.v` files to the Design Sources.
3. Add a new `.xdc` Constraints file and map the ports to the physical pins.
4. Run Synthesis, Implementation, and Generate Bitstream.
5. Program the device and connect a VGA monitor!
