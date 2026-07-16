`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// 4bit counter with reset - Testbench
//////

module tb_counter_4bit;

    reg clk; // clock
    reg reset; // reset
    wire [3:0] out;  // 4bit out
    
    counter_4bit uut(
        .clk(clk),
        .reset(reset),
        .out(out)
    );
    
     // clock generateor
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; //change state every 5
    end
   
    //create input signal
    initial begin
        $display("----------------");
        $monitor("time: %0dns\t  reset: %b  |out: %b", $time, reset, out);

        // start
        reset = 1'b0; // pressed reset
        #12;

        reset = 1'b1; // release reset
        // counter starts after 12 -> at 15
        
        //let it run for a long
        #200;
        
        // test reset - shuld be 0 immediatly
        reset = 1'b0;
        #10;

        $finish;
    end
        
endmodule
