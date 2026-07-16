`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// multiplexer 4 to 1 - Testbench
//////

module mux_4_1_tb;

    reg a, b, c, d;
    reg [1:0] s;
    wire out;

    mux_4_1 uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .s(s),
        .out(out)
    );

    // auto
        localparam vars_num = 6; //a, b, c, d, s
        localparam possibple_combos = 2**vars_num ;
        integer i;
        
    initial begin
        $display("----------------");
        $monitor("a=%b, b=%b, c=%b, d=%b, s=%b, out=%b", a, b, c, d, s, out);
        
        for (i = 0; i < possibple_combos; i = i + 1) begin
            a = i[0];
            b = i[1];
            c = i[2];
            d = i[3];
            s[0] = i[4]; // selection 1bit
            s[1] = i[5]; // selection 2ndbit

            #10;
        end
        $finish;
    end

endmodule
