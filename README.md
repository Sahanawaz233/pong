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

## Hardware Connections (Digilent Zybo)
- **Clock**: `K17` (125 MHz)
- **Buttons**:
  - `BTN0` - Move Paddle Left
  - `BTN1` - Move Paddle Right
  - `BTN3` - Reset Game
- **VGA Output**: Built-in Zybo VGA port (12-bit color 4:4:4)

## How to Run
1. Create a new RTL project in Xilinx Vivado.
2. Add all `.v` files to the Design Sources.
3. Add a new `.xdc` Constraints file and map the ports to the physical pins.
4. Run Synthesis, Implementation, and Generate Bitstream.
5. Program the device and connect a VGA monitor!
