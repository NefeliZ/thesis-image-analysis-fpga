`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// decoder 3-to-8 - testbench
// 
//////

module tb_decoder_3_8;

    reg [2:0] a; //3bit
    reg en; //enable, like selection
    wire [7:0] out; //8bit
    
    decoder_3_8 uut (
        .a(a),
        .en(en),
        .out(out)
    );
    
    
    localparam vars_num = 4; // 3bits for a + 1bit for en
    localparam possible_combos = 2**vars_num;
    integer i;

    initial begin
        $display("----------------");
        $monitor("a=%b, en=%b, out=%b", a, en, out);
        
        for (i = 0; i < possible_combos; i = i + 1) begin
            a[0] = i[0]; // bit 0 -> LSB of a
            a[1] = i[1]; // bit 1 -> mid of a
            a[2] = i[2]; // bit 2 -> MSB of a
            en = i[3]; // bit 3 -> control enable
            #10; 
        end
        
        $finish;
    end
    
endmodule
