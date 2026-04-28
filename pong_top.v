`timescale 1ns / 1ps

/*
 * FPGA-based VGA Mini Game Engine (Pong)
 * Top Level Module
 * 
 * Pin mapping for Digilent Zybo (Zynq-7000):
 * clk       : L16 (125 MHz oscillator)
 * btn_left  : P16 (BTN1)
 * btn_right : V16 (BTN2)
 * btn_reset : R18 (BTN0)
 * hsync     : P19 (VGA_HS)
 * vsync     : R19 (VGA_VS)
 * vga_r[3:0]: F20, G20, J20, L20  (Zybo VGA_R 4,3,2,1)
 * vga_g[3:0]: F19, H20, J19, L19  (Zybo VGA_G 5,4,3,2)
 * vga_b[3:0]: G19, J18, K19, M20  (Zybo VGA_B 4,3,2,1)
 *
 * Note: Zybo supports up to 16-bit color. We map our 12-bit output to the
 * most significant bits of the Zybo VGA port for maximum brightness.
 */

module pong_top (
    input wire clk,          // 125MHz system clock
    input wire btn_left,     // Button to move left
    input wire btn_right,    // Button to move right
    input wire btn_reset,    // Active-high reset button
    
    // VGA Outputs (12-bit color 4:4:4)
    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    // Internal signals
    wire pixel_clk;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire [9:0] paddle_x;
    wire [9:0] paddle_y;
    wire [9:0] ball_x;
    wire [9:0] ball_y;
    wire [11:0] rgb;
    
    // Map internal 12-bit RGB to separate 4-bit output ports
    assign vga_r = rgb[11:8];
    assign vga_g = rgb[7:4];
    assign vga_b = rgb[3:0];

    // 1. Clock Divider (125MHz -> 25MHz pixel clock)
    clk_divider u_clk_div (
        .clk(clk),
        .reset(btn_reset),
        .pixel_clk(pixel_clk)
    );

    // 2. VGA Controller / Timing Generator
    vga_sync u_vga_sync (
        .pixel_clk(pixel_clk),
        .reset(btn_reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .p_tick(), // Left unconnected, not strictly needed outside
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // 3. Game Logic (Physics, collisions, inputs)
    game_logic u_game_logic (
        .clk(pixel_clk),
        .reset(btn_reset),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .vsync(vsync),     // Update state once per frame
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y)
    );

    // 4. Rendering Engine (Pixel color generation)
    pixel_gen u_pixel_gen (
        .clk(pixel_clk),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .rgb(rgb)
    );

endmodule
