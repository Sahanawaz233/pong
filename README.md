# 🎮 FPGA VGA Pong Game (Verilog HDL)

A real-time, hardware-driven 2-player **Pong** game implemented entirely in synthesizable **Verilog HDL**. 

This project features a fully custom VGA timing generator, game physics engine, and a dual-scoreboard display rendered on-the-fly. It is tailored for the **Digilent Zybo Zynq-7000** board (using its 125 MHz onboard oscillator) but can be easily adapted to other FPGA boards with VGA output.

---

## ✨ Features

*   **VGA Timing Generator**: Generates 640x480 @ 60Hz resolution sync signals using a custom divider clock.
*   **Dual Scoreboard Renderers**: Custom-designed 7-segment digital scoreboard rendered directly in hardware, featuring an aesthetic "ghost segment" style where inactive segments are visible in a dimmer color.
*   **Neon Design Theme**: Vibrant 16-bit RGB565 color palette:
    *   **P1 Paddle & Score**: Neon Cyan 🟦
    *   **P2 Paddle & Score**: Neon Magenta 🟥
    *   **Ball**: Bright Yellow 🟡
    *   **Background**: Midnight Blue 🌌
*   **Real-time Game Physics**: Wall bouncing, paddle collisions, and boundary score triggers.
*   **Win State & Reset**: The first player to reach **9 points** wins. The winning player's score blinks on screen for ~4 seconds before resetting the scores and serving the ball to the loser.
*   **Hardware Control**: Inputs are mapped to tactile buttons for movement and a slide switch for resetting the game.

---

## 🛠️ System Architecture & File Structure

The project is designed with modular separation of concerns:

*   [`pong_top.v`](pong_top.v) – The top-level module connecting inputs, clock divider, VGA sync generator, game logic, and the pixel color generator.
*   [`clk_divider.v`](clk_divider.v) – Divides the 125 MHz Zybo system clock down to the target 25 MHz VGA pixel clock.
*   [`vga_sync.v`](vga_sync.v) – Generates horizontal (`HSYNC`) and vertical (`VSYNC`) synchronization signals alongside current pixel coordinates.
*   [`game_logic.v`](game_logic.v) – Handles paddle movements, ball trajectory physics, wall bounces, paddle collision detection, and score tracking.
*   [`pixel_gen.v`](pixel_gen.v) – Generates the color for each coordinate based on the current states of paddles, ball, net, and scoreboards.
*   [`seven_segment_pixel.v`](seven_segment_pixel.v) – A graphics module that decodes digit values into coordinate-mapped 7-segment numbers.
*   [`zybo_constraints.xdc`](zybo_constraints.xdc) – Xilinx Design Constraints file mapping ports to physical pins on the Zybo board.
*   [`tb_pong_top.v`](tb_pong_top.v) / [`tb_pong_image.v`](tb_pong_image.v) – Simulation testbenches.

---

## 🔌 Hardware Connections & Constraints (Zybo Rev B)

**Target Device:** `xc7z010clg400-1`

| Port Name | Zybo Pin | Description |
| :--- | :---: | :--- |
| `clk` | **L16** | 125 MHz Onboard Oscillator |
| `sw[0]` | **G15** | Slide Switch 0 (Reset Game) |
| `btn[0]` | **R18** | Button 0 (Player 1 Move Up) |
| `btn[1]` | **P16** | Button 1 (Player 1 Move Down) |
| `btn[2]` | **V16** | Button 2 (Player 2 Move Up) |
| `btn[3]` | **Y16** | Button 3 (Player 2 Move Down) |
| `vga_hs` | **P19** | Horizontal Sync Output |
| `vga_vs` | **R19** | Vertical Sync Output |
| `vga_r[4:0]` | *Multiple* | Red channel (5-bit) |
| `vga_g[5:0]` | *Multiple* | Green channel (6-bit) |
| `vga_b[4:0]` | *Multiple* | Blue channel (5-bit) |

*Refer to [`zybo_constraints.xdc`](zybo_constraints.xdc) for detailed bit-by-bit physical pin allocations.*

---

## 🚀 How to Run

1. Open **Xilinx Vivado** and create a new RTL Project.
2. Select target chip `xc7z010clg400-1` (or your Zybo board configuration).
3. Import all `.v` files under Design Sources.
4. Import [`zybo_constraints.xdc`](zybo_constraints.xdc) under Constraints.
5. Click **Run Synthesis** followed by **Run Implementation**.
6. Select **Generate Bitstream**.
7. Connect your Zybo board via USB and plug a monitor into the VGA port.
8. Open Hardware Manager, program the FPGA, and enjoy the game!
