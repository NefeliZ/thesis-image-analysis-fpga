`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// decoder 2-to-4
// 
//////

module decoder_2_4(
    input wire [1:0] a, //2bit
    input wire en, //enable, like selection
    output reg [3:0] out //4bit
    );
    
    always @(*) begin //sensitive at any var
        if (en == 1'b0) begin
            out = 4'b0000;  //if enable is 0, all outputs are off
        end 
        else begin
            case (a)//diff val at each diff case 
                2'b00: out = 4'b0001; 
                2'b01: out = 4'b0010; 
                2'b10: out = 4'b0100; 
                2'b11: out = 4'b1000; 
                default: out = 4'b0000; //default for safety
            endcase
        end
    end
endmodule
