`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// decoder 2-to-4 - testbench
// 
//////

module tb_decoder_2_4;

    reg [1:0] a; //2bit
    reg en; //enable, like selection
    wire [3:0] out; //4bit
    
    decoder_2_4 uut (
        .a(a),
        .en(en),
        .out(out)
    );
    
    
    localparam vars_num = 3; // 2bits for a + 1bit for en
    localparam possible_combos = 2**vars_num;
    integer i;

    initial begin
        $display("----------------");
        $monitor("a=%b, en=%b, out=%b", a, en, out);
        
        for (i = 0; i < possible_combos; i = i + 1) begin
            a[0] = i[0]; // bit 0 -> LSB of a
            a[1] = i[1]; // bit 1 -> MSB of a
            en   = i[2]; // bit 2 -> control enable
            #10; 
        end
        
        $finish;
    end
    
endmodule
