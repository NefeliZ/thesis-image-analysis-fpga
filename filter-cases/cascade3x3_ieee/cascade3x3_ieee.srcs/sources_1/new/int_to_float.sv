`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// turn int to flot - ieee format
// 
//////

module int_to_float (
    input logic [7:0] input_bin, //input 8bit bin number
    output logic [31:0] output_float
);
    
    logic sign;
    logic [7:0] exponent;
    logic [22:0] mantissa;
    //logic [31:0] input_bin_32b;
    
    //all input numbers are positive (0-255)
    //set 31st as sign
    assign sign = 1'b0; //0=positive
    
        
    always_comb begin
        //if its 0
        if (input_bin == 8'b0) begin
            exponent = 8'd0;
            mantissa = 23'b0;
            output_float = 32'b0;
        end
        //exponent is 127 + position of MSB
        //mantissa is the rest + 0s to make it 23bit
        else if (input_bin[7]) begin //MSB is at 7
            exponent = 8'd127 + 8'd7;
            mantissa = {input_bin[6:0], 16'b0}; //7+16=23bit
        end
        else if (input_bin[6]) begin //MSB is at 6
            exponent = 8'd127 + 8'd6;
            mantissa = {input_bin[5:0], 17'b0};
        end
        else if (input_bin[5]) begin //MSB is at 5
            exponent = 8'd127 + 8'd5;
            mantissa = {input_bin[4:0], 18'b0};
        end
        else if (input_bin[4]) begin //MSB is at 4
            exponent = 8'd127 + 8'd4;
            mantissa = {input_bin[3:0], 19'b0};
        end
        else if (input_bin[3]) begin //MSB is at 3
            exponent = 8'd127 + 8'd3;
            mantissa = {input_bin[2:0], 20'b0};
        end
        else if (input_bin[2]) begin //MSB is at 2
            exponent = 8'd127 + 8'd2;
            mantissa = {input_bin[1:0], 21'b0};
        end
        else if (input_bin[1]) begin //MSB is at 1
            exponent = 8'd127 + 8'd1;
            mantissa = {input_bin[0], 22'b0};
        end
        else begin //MSB at 0
            exponent = 8'd127 + 8'd0;
            mantissa = 23'b0;
        end
        
        output_float = {sign, exponent, mantissa};
    end

endmodule
