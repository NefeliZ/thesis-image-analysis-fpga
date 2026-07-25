`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// FSM counter me overflow - testbench
//////

module tb_fsm_counter;

    parameter width = 4;

    logic clk;
    logic reset;
    logic act;
    logic up_down;
    logic [width-1:0] count;
    logic ovflw;

    // instantiation
    fsm_counter #(
        .counter_width(width)
    ) uut (
        .clk(clk),
        .reset(reset),
        .act(act),
        .up_down(up_down),
        .count(count),
        .ovflw(ovflw)
    );

    // clock setup
    initial begin
        clk = 1'b1;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("----------------");
        $monitor("%0dns\t   %b   |  %b  |    %b     |  %d   |   %b", $time, reset, act, up_down, count, ovflw);

        // setup &
        reset = 1'b0;
        act = 1'b0;
        up_down = 1'b1;
        
        #20 
        reset = 1'b1;

        // count up -> act = 1 up_down=1
        #10 
        act = 1'b1; 
        up_down = 1'b1;

        // let it hit overlow
        #180;

        // pulse reset -> clean overlfow
        reset = 1'b0;
        #10;
        reset = 1'b1;
        act = 1'b0;

        // count down -> act = 1 up_down = 0
        #20;
        act = 1'b1;
        up_down = 1'b0; // count down
        
        #50;

        $finish;
    end

endmodule