`timescale 1ns / 1ps

module clk_divider (
    input clk,          // System clock (100 MHz)
    input reset,        // Asynchronous reset
    output reg pixel_clk // Pixel clock (25 MHz)
);

    reg [2:0] count;

    // Divide 125 MHz by 5 to get 25 MHz
    // Count goes 0, 1, 2, 3, 4 then repeats
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 3'b000;
            pixel_clk <= 1'b0;
        end else begin
            if (count == 3'd4) begin
                count <= 3'b000;
            end else begin
                count <= count + 1;
            end
            
            // Generate a clock pulse (duty cycle will be 40% high, 60% low, which is fine for VGA)
            if (count < 3'd2) begin
                pixel_clk <= 1'b1;
            end else begin
                pixel_clk <= 1'b0;
            end
        end
    end

endmodule
