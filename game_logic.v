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
    output reg [9:0] ball_y,
    output reg [3:0] score1,
    output reg [3:0] score2,
    output wire score1_visible,
    output wire score2_visible
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

    // Win state registers and counters
    reg win_state;
    reg win_player;
    reg [7:0] win_timer;
    reg flash_on;
    reg [5:0] frame_counter;

    assign score1_visible = !(win_state && win_player == 1'b0 && !flash_on);
    assign score2_visible = !(win_state && win_player == 1'b1 && !flash_on);

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
            score1 <= 4'd0;
            score2 <= 4'd0;
            win_state <= 1'b0;
            win_player <= 1'b0;
            win_timer <= 8'd0;
            flash_on <= 1'b1;
            frame_counter <= 6'd0;
        end else if (vsync_edge) begin
            // Frame counter for flashing score
            frame_counter <= frame_counter + 1'b1;
            if (frame_counter == 6'd29) begin
                frame_counter <= 6'd0;
                flash_on <= ~flash_on;
            end

            if (win_state) begin
                // Win state celebration: count frames to reset
                win_timer <= win_timer + 1'b1;
                if (win_timer >= 8'd240) begin // ~4 seconds at 60Hz
                    // Reset scores and go back to playing
                    score1 <= 4'd0;
                    score2 <= 4'd0;
                    win_state <= 1'b0;
                    win_timer <= 8'd0;
                    // Reset ball
                    ball_x <= (MAX_X - BALL_S) / 2;
                    ball_y <= (MAX_Y - BALL_S) / 2;
                    x_dir <= ~win_player; // Serve to the player who lost
                end
            end else begin
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
                        score1 <= score1 + 1'b1;
                        ball_x <= (MAX_X - BALL_S) / 2; // Reset ball to center
                        ball_y <= (MAX_Y - BALL_S) / 2;
                        if (score1 == 4'd8) begin // Will become 9
                            win_state <= 1'b1;
                            win_player <= 1'b0; // Player 1 wins
                            win_timer <= 8'd0;
                        end else begin
                            x_dir <= 1'b0; // Serve to Player 1
                        end
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
                        score2 <= score2 + 1'b1;
                        ball_x <= (MAX_X - BALL_S) / 2; // Reset ball to center
                        ball_y <= (MAX_Y - BALL_S) / 2;
                        if (score2 == 4'd8) begin // Will become 9
                            win_state <= 1'b1;
                            win_player <= 1'b1; // Player 2 wins
                            win_timer <= 8'd0;
                        end else begin
                            x_dir <= 1'b1; // Serve to Player 2
                        end
                    end else begin
                        ball_x <= ball_x - BALL_V;
                    end
                end
            end
        end
    end

endmodule
