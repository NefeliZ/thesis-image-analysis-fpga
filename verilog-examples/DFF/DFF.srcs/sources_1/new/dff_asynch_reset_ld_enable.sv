`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// DFF asynchronous me reset & load enable
//////

module dff_asynch_reset_ld_enable (
    input  logic clk,
    input  logic reset,//asynch reset
    input  logic load_enable, // enalbe
    input  logic d,  //input daata 
    output logic q // output
);

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            q <= 1'b0; //reset=0 output=0 immediatley(assyncrh)
        end else if (load_enable) begin
            q <= d;//eanble=1 -> update output
        end
    end

endmodule
