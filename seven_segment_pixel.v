`timescale 1ns / 1ps

module seven_segment_pixel (
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [9:0] digit_x,
    input wire [9:0] digit_y,
    input wire [3:0] digit_val,
    output reg pixel_active,
    output reg pixel_inactive
);
    localparam DIGIT_W = 40;
    localparam DIGIT_H = 60;
    localparam SEG_T = 6; // Segment thickness

    // Get coordinates relative to digit top-left
    wire [9:0] dx = (pixel_x >= digit_x) ? (pixel_x - digit_x) : 10'd1023;
    wire [9:0] dy = (pixel_y >= digit_y) ? (pixel_y - digit_y) : 10'd1023;

    // Check if pixel is within digit bounds
    wire in_bounds = (dx < DIGIT_W) && (dy < DIGIT_H);

    // Decode segment signals (active high)
    // Segments are: seg[6]=A, seg[5]=B, seg[4]=C, seg[3]=D, seg[2]=E, seg[1]=F, seg[0]=G
    reg [6:0] seg; 
    always @(*) begin
        case (digit_val)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110000;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b0000000;
        endcase
    end

    // Define coordinate ranges for each segment
    // A: top horizontal segment
    wire seg_a = (dx >= SEG_T) && (dx < DIGIT_W - SEG_T) && (dy < SEG_T);
    // B: top right vertical segment
    wire seg_b = (dx >= DIGIT_W - SEG_T) && (dy >= SEG_T) && (dy < DIGIT_H/2);
    // C: bottom right vertical segment
    wire seg_c = (dx >= DIGIT_W - SEG_T) && (dy >= DIGIT_H/2) && (dy < DIGIT_H - SEG_T);
    // D: bottom horizontal segment
    wire seg_d = (dx >= SEG_T) && (dx < DIGIT_W - SEG_T) && (dy >= DIGIT_H - SEG_T);
    // E: bottom left vertical segment
    wire seg_e = (dx < SEG_T) && (dy >= DIGIT_H/2) && (dy < DIGIT_H - SEG_T);
    // F: top left vertical segment
    wire seg_f = (dx < SEG_T) && (dy >= SEG_T) && (dy < DIGIT_H/2);
    // G: middle horizontal segment
    wire seg_g = (dx >= SEG_T) && (dx < DIGIT_W - SEG_T) && (dy >= (DIGIT_H/2 - SEG_T/2)) && (dy < (DIGIT_H/2 + SEG_T/2));

    // Any segment pixel at all
    wire any_seg = seg_a || seg_b || seg_c || seg_d || seg_e || seg_f || seg_g;

    always @(*) begin
        if (!in_bounds) begin
            pixel_active = 1'b0;
            pixel_inactive = 1'b0;
        end else begin
            pixel_active = (seg[6] && seg_a) ||
                           (seg[5] && seg_b) ||
                           (seg[4] && seg_c) ||
                           (seg[3] && seg_d) ||
                           (seg[2] && seg_e) ||
                           (seg[1] && seg_f) ||
                           (seg[0] && seg_g);
            pixel_inactive = any_seg && !pixel_active;
        end
    end
endmodule
