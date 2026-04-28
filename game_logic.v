`timescale 1ns / 1ps

module game_logic (
    input wire clk,          // pixel clock (25 MHz)
    input wire reset,        // reset
    input wire btn_left,     // move paddle left
    input wire btn_right,    // move paddle right
    input wire vsync,        // vertical sync from vga controller
    
    // Outputs
    output reg [9:0] paddle_x,
    output wire [9:0] paddle_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y
);

    // Screen dimensions
    localparam MAX_X = 640;
    localparam MAX_Y = 480;

    // Paddle dimensions and properties
    localparam PADDLE_W = 64;
    localparam PADDLE_H = 10;
    localparam PADDLE_V = 5;  // Paddle velocity (pixels per frame)

    // Ball dimensions and properties
    localparam BALL_S = 8;    // Ball size (8x8)
    localparam BALL_V = 3;    // Ball velocity (pixels per frame)

    // Paddle Y position is fixed near the bottom
    assign paddle_y = MAX_Y - 40;

    // Ball movement direction (1 = right/down, 0 = left/up)
    reg x_dir; 
    reg y_dir; 
    
    // Edge detection for vsync to update on frame end (falling edge)
    reg vsync_reg;
    wire vsync_edge = (vsync_reg & ~vsync); // Falling edge of vsync means end of frame

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            vsync_reg <= 1'b0;
        end else begin
            vsync_reg <= vsync;
        end
    end

    // Game logic update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset game state
            paddle_x <= (MAX_X - PADDLE_W) / 2;
            ball_x <= (MAX_X - BALL_S) / 2;
            ball_y <= (MAX_Y - BALL_S) / 2;
            x_dir <= 1'b1; // Start moving right
            y_dir <= 1'b1; // Start moving down
        end else if (vsync_edge) begin
            // UPDATE PADDLE
            if (btn_left && (paddle_x > PADDLE_V)) begin
                paddle_x <= paddle_x - PADDLE_V;
            end else if (btn_right && (paddle_x < (MAX_X - PADDLE_W - PADDLE_V))) begin
                paddle_x <= paddle_x + PADDLE_V;
            end

            // UPDATE BALL X-AXIS
            if (x_dir == 1'b1) begin // Moving right
                if (ball_x >= (MAX_X - BALL_S - BALL_V)) begin
                    ball_x <= MAX_X - BALL_S;
                    x_dir <= 1'b0; // Reverse direction to left
                end else begin
                    ball_x <= ball_x + BALL_V;
                end
            end else begin // Moving left
                if (ball_x <= BALL_V) begin
                    ball_x <= 0;
                    x_dir <= 1'b1; // Reverse direction to right
                end else begin
                    ball_x <= ball_x - BALL_V;
                end
            end

            // UPDATE BALL Y-AXIS
            if (y_dir == 1'b1) begin // Moving down
                // Check paddle collision
                // Paddle is at paddle_y to paddle_y + PADDLE_H
                // Ball bottom is ball_y + BALL_S
                if ( (ball_y + BALL_S + BALL_V) >= paddle_y && 
                     (ball_y) <= (paddle_y + PADDLE_H) &&
                     (ball_x + BALL_S) >= paddle_x && 
                     (ball_x) <= (paddle_x + PADDLE_W) ) begin
                    // Hit the paddle
                    ball_y <= paddle_y - BALL_S;
                    y_dir <= 1'b0; // Bounce up
                end else if (ball_y >= (MAX_Y - BALL_S - BALL_V)) begin
                    // Hit bottom wall
                    ball_y <= MAX_Y - BALL_S;
                    y_dir <= 1'b0; // Bounce up
                end else begin
                    ball_y <= ball_y + BALL_V;
                end
            end else begin // Moving up
                if (ball_y <= BALL_V) begin
                    ball_y <= 0;
                    y_dir <= 1'b1; // Bounce down
                end else begin
                    ball_y <= ball_y - BALL_V;
                end
            end
        end
    end

endmodule
