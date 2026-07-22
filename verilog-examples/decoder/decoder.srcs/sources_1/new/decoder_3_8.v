`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// decoder 3-to-8
// 
//////

module decoder_3_8(
    input wire [2:0] a, //3bit
    input wire en, //enable, like selection
    output reg [7:0] out //8bit
    );
    
    always @(*) begin //sensitive at any var
        if (en == 1'b0) begin
            out = 8'b0000_0000;  //if enable is 0, all outputs are off
        end 
        else begin
        // case goes me seira
            case (a)//diff val at each diff case 
                3'b000: out = 8'b0000_0001; // 0000_move 1 position
                3'b001: out = 8'b0000_0010; 
                3'b010: out = 8'b0000_0100; 
                3'b011: out = 8'b0000_1000; 
                3'b100: out = 8'b0001_0000; // move 1 position_00000
                3'b101: out = 8'b0010_0000;
                3'b110: out = 8'b0100_0000;
                3'b111: out = 8'b1000_0000;
                default: out = 8'b0000_0000; //default
            endcase
        end
    end
endmodule
