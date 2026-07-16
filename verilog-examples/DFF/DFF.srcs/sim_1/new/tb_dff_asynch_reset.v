`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// DFF asynchronous me reset - Testbench
//////


module tb_dff_asynch_reset;

     reg clk; //clock
     reg reset; // asynchr reset 
     reg in;  // input data
     wire out;    // output 

    dff_asynch_reset uut(
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

    //create input signal
    initial begin
        $display("----------------");
        $monitor("time: %0dns\t  reset: %b   |in: %b |out: %b", $time, reset, in, out);

        // start
        reset = 1'b0; // pressed reset
        in = 1'b0;
        #12; // #5: 1 #10:0 -> after 10 goes 0->1 -> wait 12

        reset = 1'b1; // release reset
        #4; //tot: #16         

        //input =1 - out not 1, will be 1 at posedge -> at #25
        in = 1'b1; 
        #20; //#35

        // input =0 - out not 0, will be 0 at posedge -> at #45
        in = 1'b0;
        #20;

        //test - change input not at posedge
        in = 1'b1;
        #10; // d = 1, q = 1
        #3; 
        // test reset - shuld be 0 immediatly
        reset = 1'b0;
        #10;

        $finish;
    end
endmodule
