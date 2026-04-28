`timescale 1ns / 1ps

module vga_sync (
    input wire pixel_clk,  // 25 MHz pixel clock
    input wire reset,      // Asynchronous reset
    output reg hsync,      // Horizontal sync (active low)
    output reg vsync,      // Vertical sync (active low)
    output wire video_on,  // 1 when within active display area
    output wire p_tick,    // Pixel tick (1 for 1 clock cycle)
    output wire [9:0] pixel_x, // Current X coordinate
    output wire [9:0] pixel_y  // Current Y coordinate
);

    // VGA Timing parameters for 640x480 @ 60Hz
    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    // Horizontal and vertical counters
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;

    // Output buffers
    reg h_sync_reg, vsync_reg;
    wire h_sync_next, vsync_next;

    // Register operations
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            hsync <= 1'b1; // idle high
            vsync <= 1'b1; // idle high
        end else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            hsync <= h_sync_next;
            vsync <= vsync_next;
        end
    end

    // Horizontal and vertical counter logic
    always @* begin
        h_count_next = h_count_reg;
        v_count_next = v_count_reg;
        
        if (h_count_reg == (H_TOTAL - 1)) begin
            h_count_next = 0;
            if (v_count_reg == (V_TOTAL - 1)) begin
                v_count_next = 0;
            end else begin
                v_count_next = v_count_reg + 1;
            end
        end else begin
            h_count_next = h_count_reg + 1;
        end
    end

    // Horizontal and vertical sync signals
    // HSYNC is low between (H_DISPLAY + H_FRONT) and (H_DISPLAY + H_FRONT + H_SYNC - 1)
    assign h_sync_next = (h_count_reg >= (H_DISPLAY + H_FRONT) && 
                          h_count_reg <= (H_DISPLAY + H_FRONT + H_SYNC - 1)) ? 1'b0 : 1'b1;

    // VSYNC is low between (V_DISPLAY + V_FRONT) and (V_DISPLAY + V_FRONT + V_SYNC - 1)
    assign vsync_next = (v_count_reg >= (V_DISPLAY + V_FRONT) && 
                         v_count_reg <= (V_DISPLAY + V_FRONT + V_SYNC - 1)) ? 1'b0 : 1'b1;

    // Video On signal (active only in display area)
    assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);
    
    // Pixel tick is always 1 for this design since we drive it with 25MHz clock directly
    assign p_tick = 1'b1;

    // Output coordinates
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule
