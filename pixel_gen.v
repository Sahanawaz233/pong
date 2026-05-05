`timescale 1ns / 1ps

module pixel_gen (
    input wire clk,
    input wire video_on,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [9:0] paddle_x,
    input wire [9:0] paddle_y,
    input wire [9:0] ball_x,
    input wire [9:0] ball_y,
    output reg [15:0] rgb
);

    // Paddle dimensions (matches game_logic)
    localparam PADDLE_W = 64;
    localparam PADDLE_H = 10;
    
    // Ball dimension (matches game_logic)
    localparam BALL_S = 8;
    
    // Colors (16-bit RGB format: 5-bits Red, 6-bits Green, 5-bits Blue)
    localparam COLOR_BG     = 16'h0000; // Black background
    localparam COLOR_PADDLE = 16'h07E0; // Green paddle (RGB565)
    localparam COLOR_BALL   = 16'hF800; // Red ball (RGB565)
    
    // Combinational logic to check if current pixel is inside the paddle or ball
    wire paddle_on = (pixel_x >= paddle_x) && (pixel_x < paddle_x + PADDLE_W) &&
                     (pixel_y >= paddle_y) && (pixel_y < paddle_y + PADDLE_H);
                     
    wire ball_on = (pixel_x >= ball_x) && (pixel_x < ball_x + BALL_S) &&
                   (pixel_y >= ball_y) && (pixel_y < ball_y + BALL_S);
                   
    // Output RGB color based on pixel position
    always @(*) begin
        if (!video_on) begin
            rgb = 12'h000; // Display must be black outside active video region
        end else begin
            if (paddle_on) begin
                rgb = COLOR_PADDLE;
            end else if (ball_on) begin
                rgb = COLOR_BALL;
            end else begin
                rgb = COLOR_BG;
            end
        end
    end

endmodule
