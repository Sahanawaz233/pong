`timescale 1ns / 1ps

module game_logic (
    input wire clk,          // pixel clock (25 MHz)
    input wire reset,        // reset from switch 0
    input wire [3:0] btn,    // 4 push buttons
    input wire vsync,        // vertical sync from vga controller
    
    // Outputs
    output reg [9:0] paddle1_y,
    output reg [9:0] paddle2_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y
);

    // Screen dimensions
    localparam MAX_X = 640;
    localparam MAX_Y = 480;

    // Paddle dimensions and properties (Vertical paddles)
    localparam PADDLE_W = 12; // Width is thin
    localparam PADDLE_H = 80; // Height is long
    localparam PADDLE_V = 6;  // Paddle velocity

    // Fixed X positions for paddles
    localparam PADDLE1_X = 30; // Player 1 on the left
    localparam PADDLE2_X = MAX_X - 30 - PADDLE_W; // Player 2 on the right

    // Ball dimensions and properties
    localparam BALL_S = 10;   // Ball size (10x10)
    localparam BALL_V = 4;    // Ball velocity (pixels per frame)

    // Ball movement direction (1 = right/down, 0 = left/up)
    reg x_dir; 
    reg y_dir; 
    
    // Edge detection for vsync to update on frame end (falling edge)
    reg vsync_reg;
    wire vsync_edge = (vsync_reg & ~vsync); // Falling edge

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
            // Reset game state to center
            paddle1_y <= (MAX_Y - PADDLE_H) / 2;
            paddle2_y <= (MAX_Y - PADDLE_H) / 2;
            ball_x <= (MAX_X - BALL_S) / 2;
            ball_y <= (MAX_Y - BALL_S) / 2;
            x_dir <= 1'b1; // Start moving right
            y_dir <= 1'b1; // Start moving down
        end else if (vsync_edge) begin
            // UPDATE PLAYER 1 PADDLE (Left, BTN0=Up, BTN1=Down)
            // Note: Screen Y goes from 0 (top) to 480 (bottom)
            if (btn[0] && (paddle1_y > PADDLE_V)) begin
                paddle1_y <= paddle1_y - PADDLE_V; // Move Up
            end else if (btn[1] && (paddle1_y < (MAX_Y - PADDLE_H - PADDLE_V))) begin
                paddle1_y <= paddle1_y + PADDLE_V; // Move Down
            end

            // UPDATE PLAYER 2 PADDLE (Right, BTN2=Up, BTN3=Down)
            if (btn[2] && (paddle2_y > PADDLE_V)) begin
                paddle2_y <= paddle2_y - PADDLE_V; // Move Up
            end else if (btn[3] && (paddle2_y < (MAX_Y - PADDLE_H - PADDLE_V))) begin
                paddle2_y <= paddle2_y + PADDLE_V; // Move Down
            end

            // UPDATE BALL Y-AXIS (Bouncing off Top and Bottom walls)
            if (y_dir == 1'b1) begin // Moving down
                if (ball_y >= (MAX_Y - BALL_S - BALL_V)) begin
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

            // UPDATE BALL X-AXIS (Paddle Collisions & Scoring)
            if (x_dir == 1'b1) begin // Moving Right towards Player 2
                // Check Player 2 Paddle collision
                if ( (ball_x + BALL_S + BALL_V) >= PADDLE2_X && 
                     (ball_x) <= (PADDLE2_X + PADDLE_W) &&
                     (ball_y + BALL_S) >= paddle2_y && 
                     (ball_y) <= (paddle2_y + PADDLE_H) ) begin
                    // Hit Right Paddle
                    ball_x <= PADDLE2_X - BALL_S;
                    x_dir <= 1'b0; // Bounce left
                end else if (ball_x >= (MAX_X - BALL_S - BALL_V)) begin
                    // Player 1 Scores (Ball hit right wall)
                    ball_x <= (MAX_X - BALL_S) / 2; // Reset to center
                    ball_y <= (MAX_Y - BALL_S) / 2;
                    x_dir <= 1'b0; // Serve to Player 1
                end else begin
                    ball_x <= ball_x + BALL_V;
                end
            end else begin // Moving Left towards Player 1
                // Check Player 1 Paddle collision
                if ( (ball_x <= PADDLE1_X + PADDLE_W + BALL_V) && 
                     (ball_x + BALL_S) >= PADDLE1_X &&
                     (ball_y + BALL_S) >= paddle1_y && 
                     (ball_y) <= (paddle1_y + PADDLE_H) ) begin
                    // Hit Left Paddle
                    ball_x <= PADDLE1_X + PADDLE_W;
                    x_dir <= 1'b1; // Bounce right
                end else if (ball_x <= BALL_V) begin
                    // Player 2 Scores (Ball hit left wall)
                    ball_x <= (MAX_X - BALL_S) / 2; // Reset to center
                    ball_y <= (MAX_Y - BALL_S) / 2;
                    x_dir <= 1'b1; // Serve to Player 2
                end else begin
                    ball_x <= ball_x - BALL_V;
                end
            end
        end
    end

endmodule
