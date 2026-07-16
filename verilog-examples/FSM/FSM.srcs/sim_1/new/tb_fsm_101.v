`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// FSM 101 sequence detector - testbench
//////


module tb_fsm_101;
    reg clk;
    reg reset;
    reg in;
    wire out;
    
    fsm_101 uut(
        .clk(clk),
        .reset(reset),
        .in(in),
        .out(out)
    );
    
    // clock generateor
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; //change state every 5
    end
    
    initial begin
        $display("----------------");
        $monitor("time: %0dns\t  reset: %b   |in: %b | curr state: %b | out: %b", $time, reset, in, uut.curr_state, out);

        // start
        reset = 1'b0; // pressed reset
        in = 1'b0;
        #12; // #5: 1 #10:0 -> after 10 goes 0->1 -> wait 12

        reset = 1'b1; // release reset
        #4; //tot: #16         

        in = 1'b0; #10; // in=0 -> 00
        in = 1'b1; #10; // in=1 -> 01 - got 1
        in = 1'b0; #10; // in=0 -> 10 - got 10
        in = 1'b1; #10; // in=1 -> 01 - got 101 -> out=1
        
        in = 1'b1; #10; // in=1 -> 11 so it keep 01
        in = 1'b0; #10; // in=0 ->10 - got 10
        in = 1'b0; #10; // in=0 -> 00
        in = 1'b0; #10; // in=0 -> 00
        
        #20;
        $finish;
    end
    
endmodule
