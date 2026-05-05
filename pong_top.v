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
    input wire [3:0] btn,    // 4 Push Buttons
    
    // VGA Outputs (16-bit color 5:6:5)
    output wire vga_hs,
    output wire vga_vs,
    output wire [4:0] vga_r,
    output wire [5:0] vga_g,
    output wire [4:0] vga_b
);

    // Map buttons to internal signals
    wire btn_left  = btn[0]; // BTN0
    wire btn_right = btn[1]; // BTN1
    wire btn_reset = btn[3]; // BTN3

    // Internal signals
    wire pixel_clk;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire [9:0] paddle_x;
    wire [9:0] paddle_y;
    wire [9:0] ball_x;
    wire [9:0] ball_y;
    wire [15:0] rgb;
    
    // Map internal 16-bit RGB to separate output ports
    assign vga_r = rgb[15:11]; // 5 bits Red
    assign vga_g = rgb[10:5];  // 6 bits Green
    assign vga_b = rgb[4:0];   // 5 bits Blue

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
        .hsync(vga_hs),
        .vsync(vga_vs),
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
        .vsync(vga_vs),     // Update state once per frame
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
