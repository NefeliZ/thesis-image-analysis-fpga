`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// turn float to int - ieee format
// 
//////

module float_to_int (
    input logic [31:0] input_float, //input 32bit ieee float
    output logic [7:0] output_int
);
    
    logic sign;
    logic [7:0] exponent;
    logic [22:0] mantissa;
    logic [23:0] full_mantissa;
    
    //break down inout float
    assign sign = input_float[31];
    assign exponent = input_float[30:23];
    assign mantissa = input_float[22:0];
    
    //make full M with extra 1 - 1.M
    assign full_mantissa = {1'b1, mantissa};
    
    //number A = (-1)^S * (1.M) * 2^(E-127)
    // x = E-127
    logic [7:0] shift_amount;
    
    always_comb begin
        // if sign=1-> negative or E<127-> x<0 -> A<1 its 0
        if (sign || (exponent < 8'd127)) begin
            shift_amount = 8'b0; // assign to avoid latches
            output_int = 8'd0;
        end
        //saturation 
        // if E>=135 -> x>=8 -> A>=256 -> its 255
        else if (exponent >= 8'd135) begin
            shift_amount = 8'b0; // assign to avoid latches
            output_int = 8'd255;
        end
        // normal case - between 127 <= E < 135
        //keep x digits from matissa - x=E-127
        // shift by 23-x = 23-E+127 = 150-E
        // -> shift x to the right & keep 8bit result
        else begin
            shift_amount = 8'd150 - exponent; // E=127-> shift=23 || E=134 -> shift=16
            output_int = full_mantissa >> shift_amount; //keeps [7:0] from full&shifted mantissa
        end
    end
    
endmodule
