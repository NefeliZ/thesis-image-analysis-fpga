`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// arithm & logic unit: +, -, &, | and clock-reset - testbench
//////

module tb_alu;
    logic clk; // clock
    logic reset; //reset
    logic [3:0] a; //input a
    logic [3:0] b; //input b
    logic [1:0] sel; //selection of operation
    logic [3:0] q; //output reg

    alu uut(
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .sel(sel),
        .q(q)
    );
    
    // clock generateor
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; //change state every 5
    end
    
    //create input signal
    initial begin
        $display("----------------");
        $monitor("time: %0dns\t  reset: %b   |a: %b |b: %b |sel-op: %b|out: %b", $time, reset, a, b, sel, q);

        // start
        reset = 1'b0; // pressed reset
        a = 4'd6; //se decim easier to calc fast
        b = 4'd4;
        sel = 2'b00; //+
        #12; // #5: 1 #10:0 -> after 10 goes 0->1 -> wait 12

        reset = 1'b1; // release reset
        #4; //tot: #16   
              
        sel = 2'b01; //-
        #20;
        
        a = 4'd15; //se decim easier to calc fast
        b = 4'd5;
        sel = 2'b10; //&
        #20;
        
        sel = 2'b11; //||
        #20;

        $finish;
    end
endmodule
