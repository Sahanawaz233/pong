`timescale 1ns / 1ps

module tb_pong_top();

    // Inputs
    reg clk;
    reg [3:0] btn;
    reg [0:0] sw;

    // Outputs
    wire vga_hs;
    wire vga_vs;
    wire [4:0] vga_r;
    wire [5:0] vga_g;
    wire [4:0] vga_b;

    // Instantiate the Unit Under Test (UUT)
    pong_top uut (
        .clk(clk), 
        .btn(btn), 
        .sw(sw),
        .vga_hs(vga_hs), 
        .vga_vs(vga_vs), 
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
        btn = 4'b0000;
        sw = 1'b0;
        
        // Apply Reset (SW0)
        sw[0] = 1;
        #100;
        sw[0] = 0;

        // Note: A full VGA frame takes ~16.6ms at 60Hz. 
        // Simulating a full frame can take a while in Vivado depending on your PC.
        // We will simulate for 20ms to ensure we capture at least one full VSYNC cycle.
        
        // Simulate pressing the right button (BTN1) to move the paddle
        #50000;
        btn[1] = 1;
        #5000000; // Hold for 5ms
        btn[1] = 0;
        
        #15000000; // Wait out the rest of the 20ms
        
        $display("Simulation complete. Check waveform for HSYNC and VSYNC signals.");
        $stop;
    end
      
endmodule
