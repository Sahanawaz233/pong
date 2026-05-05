`timescale 1ns / 1ps

/*
 * FPGA-based VGA Mini Game Engine (Pong)
 * Top Level Module
 * 
 * Pin mapping suggestions for Digilent Zybo / Arty S7:
 * clk       : K17 (125 MHz oscillator for Zybo) / E3 (for Arty)
 * btn_left  : (Assign to one of the 4 push buttons, e.g., BTN0)
 * btn_right : (Assign to one of the 4 push buttons, e.g., BTN1)
 * btn_reset : (Assign to one of the 4 push buttons or a slide switch)
 * hsync     : (Assign to PMOD pin for HSYNC)
 * vsync     : (Assign to PMOD pin for VSYNC)
 * vga_r     : (Assign to PMOD pins for Red)
 * vga_g     : (Assign to PMOD pins for Green)
 * vga_b     : (Assign to PMOD pins for Blue)
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
