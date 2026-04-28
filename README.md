# FPGA Pong Engine (Zybo Zynq-7000)

A real-time, hardware-level implementation of the classic Pong game written in Verilog HDL. This project synthesizes a custom VGA controller, game physics engine, and pixel rendering pipeline to run natively on the Digilent Zybo (Zynq-7000) FPGA board without the use of a microprocessor.

## Hardware Requirements
* **FPGA Board:** Digilent Zybo (Zynq-7000 XC7Z010)
* **Display:** Any VGA-compatible monitor (640x480 @ 60Hz minimum)
* **Inputs:** On-board push buttons

## Features
* **Zero-latency Hardware Logic:** True 60 FPS gameplay with physics and collision detection evaluated natively via logic gates.
* **Custom VGA Controller:** Generates strict 640x480 @ 60Hz timing signals (`hsync`, `vsync`) using a 25MHz pixel clock.
* **Dynamic Rendering Engine:** Renders a "Synthwave/Neon Arcade" theme, drawing the paddles, ball, grid, and borders procedurally without any framebuffers or external memory.
* **Fully Modular:** Clean, hierarchical Verilog design.

## Architecture / Modules
1. `pong_top.v`: The top-level wrapper that routes inputs/outputs and connects the internal modules.
2. `clk_divider.v`: Steps down the Zybo's native 125 MHz system clock to a 25 MHz pixel clock for the VGA controller.
3. `vga_sync.v`: The timing generator. Tracks the current pixel X/Y coordinates and triggers `hsync` and `vsync` pulses.
4. `game_logic.v`: The physics engine. Updates ball position, handles paddle movement, and calculates wall/paddle collisions once per frame (triggered by `vsync`).
5. `pixel_gen.v`: The rendering engine. Takes the current X/Y coordinate and outputs the correct 12-bit RGB color.

## Pin Mapping (Zybo Board)
You must apply the following constraints in your `.xdc` file in Vivado:

| Signal Name | Zybo Pin | Description |
| :--- | :--- | :--- |
| `clk` | **L16** | 125 MHz System Clock |
| `btn_reset` | **R18** | BTN0 (Reset game) |
| `btn_left` | **P16** | BTN1 (Move paddle left) |
| `btn_right` | **V16** | BTN2 (Move paddle right) |
| `hsync` | **P19** | VGA Horizontal Sync |
| `vsync` | **R19** | VGA Vertical Sync |
| `vga_r[3:0]` | **F20, G20, J20, L20** | VGA Red (MSB mapping) |
| `vga_g[3:0]` | **F19, H20, J19, L19** | VGA Green (MSB mapping)|
| `vga_b[3:0]` | **G19, J18, K19, M20** | VGA Blue (MSB mapping) |

## Simulation
This repository includes two testbenches for verification before flashing:
* `tb_pong_top.v`: A standard behavioral simulation testbench to verify clock division and VGA sync timings.
* `tb_pong_image.v`: A special testbench that simulates the rendering engine and outputs the very first generated frame into a readable `.ppm` image file!

## Getting Started
1. Create a new RTL Project in Xilinx Vivado.
2. Select the **Zybo** board (XC7Z010-1CLG400C).
3. Add all `.v` files from this repository as Design Sources.
4. Add the included `.xdc` file (or create your own using the table above) as a Constraint.
5. Generate Bitstream and program your FPGA. Plug in a VGA monitor and enjoy!
