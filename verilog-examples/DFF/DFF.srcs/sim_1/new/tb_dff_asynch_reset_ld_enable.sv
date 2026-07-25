`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// DFF asynchronous me reset & load enable - testbench
//////

module tb_dff_asynch_reset_ld_enable;

    logic clk;
    logic reset;
    logic load_enable;
    logic d;
    logic q;

    dff_asynch_reset_ld_enable uut (
        .clk(clk),
        .reset(reset),
        .load_enable(load_enable),
        .d(d),
        .q(q)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("-----------");
        $monitor("%0dns\t   %b   |      %b      | %b |   %b", $time, reset, load_enable, d, q);
        //reset
        reset       = 1'b0;
        load_enable = 1'b0;
        d           = 1'b1;
        #12;                 
        
        //load_enable = 0 
        reset = 1'b1;
        d     = 1'b1;  // input=1 but load_enable = 0
        #10;

        //load_enable = 1
        load_enable = 1'b1; //ld enable activate
        #10;

        load_enable = 1'b0; // disable enable
        d           = 1'b0; 
        #10;

        //d = 0 && load_enable = 1
        load_enable = 1'b1; 
        #10;

        $finish;
    end

endmodule