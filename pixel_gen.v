`timescale 1ns / 1ps

module pixel_gen (
    input wire clk,
    input wire video_on,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [9:0] paddle1_y,
    input wire [9:0] paddle2_y,
    input wire [9:0] ball_x,
    input wire [9:0] ball_y,
    output reg [15:0] rgb
);

    // Screen dimensions
    localparam MAX_X = 640;
    
    // Paddle dimensions (matches game_logic)
    localparam PADDLE_W = 12;
    localparam PADDLE_H = 80;
    
    // Paddle X positions (matches game_logic)
    localparam PADDLE1_X = 30;
    localparam PADDLE2_X = MAX_X - 30 - PADDLE_W;

    // Ball dimension (matches game_logic)
    localparam BALL_S = 10;
    
    // Attractive Neon Theme Colors (16-bit RGB565)
    localparam COLOR_BG     = 16'h0825; // Dark Midnight Blue
    localparam COLOR_P1     = 16'h07FF; // Neon Cyan (Player 1)
    localparam COLOR_P2     = 16'hF81F; // Neon Magenta (Player 2)
    localparam COLOR_BALL   = 16'hFFE0; // Bright Yellow (Ball)
    localparam COLOR_LINE   = 16'hFFFF; // Pure White (Net)
    
    // Combinational logic to check if current pixel is inside objects
    wire p1_on = (pixel_x >= PADDLE1_X) && (pixel_x < PADDLE1_X + PADDLE_W) &&
                 (pixel_y >= paddle1_y) && (pixel_y < paddle1_y + PADDLE_H);
                 
    wire p2_on = (pixel_x >= PADDLE2_X) && (pixel_x < PADDLE2_X + PADDLE_W) &&
                 (pixel_y >= paddle2_y) && (pixel_y < paddle2_y + PADDLE_H);
                 
    wire ball_on = (pixel_x >= ball_x) && (pixel_x < ball_x + BALL_S) &&
                   (pixel_y >= ball_y) && (pixel_y < ball_y + BALL_S);
                   
    // Dashed center line (Net)
    wire net_on = (pixel_x == MAX_X/2 || pixel_x == MAX_X/2 - 1) && (pixel_y[4] == 1'b1);
                   
    // Output RGB color based on pixel position
    always @(*) begin
        if (!video_on) begin
            rgb = 16'h0000; // Display must be black outside active video region
        end else begin
            if (p1_on) begin
                rgb = COLOR_P1;
            end else if (p2_on) begin
                rgb = COLOR_P2;
            end else if (ball_on) begin
                rgb = COLOR_BALL;
            end else if (net_on) begin
                rgb = COLOR_LINE;
            end else begin
                rgb = COLOR_BG;
            end
        end
    end

endmodule
