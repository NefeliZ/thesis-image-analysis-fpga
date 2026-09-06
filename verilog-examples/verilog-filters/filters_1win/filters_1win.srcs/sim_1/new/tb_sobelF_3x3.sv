`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 3x3 window -testbench
//////

module tb_sobelF_3x3;
    logic clk;
    logic reset;
    logic valid_in;
    logic [7:0] window [0:2][0:2];
    
    logic valid_out;
    logic [7:0] pixel_out;

    // instantiation uut
    sobelF_3x3 uut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .window(window),
        .valid_out(valid_out),
        .pixel_out(pixel_out)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // test scenario
    initial begin
        $display("--------------------------------------------------");
        $display("Starting Sobel 3x3 Testbench...");
        $display("--------------------------------------------------");

        // start
        reset = 0;
        valid_in = 0;
        // initialize vals (avoid x vals)
        for (int r=0; r<3; r++)
            for (int c=0; c<3; c++)
                window[r][c] = 8'd0;

        #20 reset = 1; // unclick reset

        // even window - all =100 
        @(posedge clk);
        #1; // delay after posedge
        valid_in = 1;
        window[0][0] = 8'd100; window[0][1] = 8'd100; window[0][2] = 8'd100;
        window[1][0] = 8'd100; window[1][1] = 8'd100; window[1][2] = 8'd100;
        window[2][0] = 8'd100; window[2][1] = 8'd100; window[2][2] = 8'd100;

        //vertical 'line': left=0 right=255 
        @(posedge clk);
        #1;
        window[0][0] = 8'd0; window[0][1] = 8'd0; window[0][2] = 8'd255;
        window[1][0] = 8'd0; window[1][1] = 8'd0; window[1][2] = 8'd255;
        window[2][0] = 8'd0; window[2][1] = 8'd0; window[2][2] = 8'd255;

        @(posedge clk);
        #1;
        valid_in = 0;

        #50;
        $finish;
    end

    //output
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Time: %0dns | Valid Output Pixel G = %d", $time, pixel_out);
        end
    end

endmodule