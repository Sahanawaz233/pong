`timescale 1ns / 1ps

module tb_pong_top();

    // Inputs
    reg clk;
    reg btn_left;
    reg btn_right;
    reg btn_reset;

    // Outputs
    wire hsync;
    wire vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    // Instantiate the Unit Under Test (UUT)
    pong_top uut (
        .clk(clk), 
        .btn_left(btn_left), 
        .btn_right(btn_right), 
        .btn_reset(btn_reset), 
        .hsync(hsync), 
        .vsync(vsync), 
        .vga_r(vga_r), 
        .vga_g(vga_g), 
        .vga_b(vga_b)
    );

    // 125MHz clock generation (8ns period)
    initial begin
        clk = 0;
        forever #4 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        btn_left = 0;
        btn_right = 0;
        
        // Apply Reset
        btn_reset = 1;
        #100;
        btn_reset = 0;

        // Note: A full VGA frame takes ~16.6ms at 60Hz. 
        // Simulating a full frame can take a while in Vivado depending on your PC.
        // We will simulate for 20ms to ensure we capture at least one full VSYNC cycle.
        
        // Simulate pressing the right button to move the paddle
        #50000;
        btn_right = 1;
        #5000000; // Hold for 5ms
        btn_right = 0;
        
        #15000000; // Wait out the rest of the 20ms
        
        $display("Simulation complete. Check waveform for HSYNC and VSYNC signals.");
        $stop;
    end
      
endmodule
