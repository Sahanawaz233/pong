`timescale 1ns / 1ps

module tb_pong_image();

    // Inputs
    reg clk;
    reg [3:0] btn;
    reg [0:0] sw;

    // Outputs
    wire hsync;
    wire vsync;
    wire [4:0] vga_r;
    wire [5:0] vga_g;
    wire [4:0] vga_b;

    // Instantiate the Unit Under Test (UUT)
    pong_top uut (
        .clk(clk), 
        .btn(btn), 
        .sw(sw), 
        .vga_hs(hsync), 
        .vga_vs(vsync), 
        .vga_r(vga_r), 
        .vga_g(vga_g), 
        .vga_b(vga_b)
    );

    // 100MHz clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // File handle for the image
    integer file;
    
    // We use Verilog's hierarchical referencing to peek inside the UUT
    // to grab the 25MHz pixel_clk and the video_on signal.
    wire video_on = uut.video_on;
    wire pixel_clk = uut.pixel_clk;
    
    reg capture_active = 0;
    reg frame_started = 0;

    initial begin
        // Initialize Inputs
        btn = 4'b0000;
        sw = 1'b0;
        sw[0] = 1;
        #100;
        sw[0] = 0;

        // Open a file to write the image
        file = $fopen("frame.ppm", "w");
        if (file == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end
        
        // Write the standard PPM image header
        // P3 = text format, 640x480 resolution, 255 = max color value
        $fwrite(file, "P3\n640 480\n255\n");
        $display("Simulation running. Waiting for the first frame to start...");
    end

    // Logic to capture exactly ONE complete frame
    always @(negedge vsync) begin
        if (!frame_started) begin
            frame_started <= 1; // Wait for the initial vsync pulse to pass
            $display("VSYNC detected. Capturing the next frame to frame.ppm...");
            capture_active <= 1;
        end else if (capture_active) begin
            capture_active <= 0; // A second vsync means the frame is over
            $fclose(file);
            $display("SUCCESS! Frame saved to frame.ppm. You can open this file in an image viewer!");
            $stop; // End simulation
        end
    end

    // Dump pixels to the file at every pixel clock tick during the active video region
    always @(posedge pixel_clk) begin
        if (capture_active && video_on) begin
            // vga_r, g, b are 5, 6, 5 bits respectively.
            // We scale them to 8-bit (0-255) for the image file.
            $fwrite(file, "%0d %0d %0d\n", vga_r * 8, vga_g * 4, vga_b * 8);
        end
    end
      
endmodule
