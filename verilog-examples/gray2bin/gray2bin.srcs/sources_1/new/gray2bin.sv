`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gray code to binary
//////

module gray2bin 
#(
    parameter size = 8 //default size
)
(
    input  logic [size-1:0] gray,//gray input
    output logic [size-1:0] bin //binary output
);

    //used only for loops
    genvar i;

    generate //create HW
        for (i = 0; i < size; i = i + 1) begin : bit_gen
            //for bit i calc XOR of i with bits i-> MSB
            assign bin[i] = ^gray[size-1:i]; //
        end
    endgenerate

endmodule