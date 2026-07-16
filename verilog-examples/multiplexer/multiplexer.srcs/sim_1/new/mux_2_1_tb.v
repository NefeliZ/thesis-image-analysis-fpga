`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// multiplexer 2 to 1 - Testbench
//////

module mux_2_1_tb;

    reg a, b, s;
    wire y;

    mux_2_1 uut (
        .a(a),
        .b(b),
        .s(s),
        .y(y)
    );

    // auto

        localparam vars_num = 3; //a, b, s
        localparam possibple_combos = 2**vars_num ;
        integer i;
        
    initial begin
        $display("----------------");
        $monitor("a=%b, b=%b, s=%b, y=%b", a, b, s, y);
        
        // krata 1 psifio tou binary i gia kathe met: 000, 001,...
        for (i = 0; i < possibple_combos; i = i + 1) begin
            a = i[0];
            b = i[1];
            s = i[2];
            #10;
        end
        $finish;
    end

    
    // manual  
//    initial begin
//        $monitor("a=%b, b=%b, s=%b, y=%b", a, b, s, y);

//        // all possible combos - s=0
//        a = 0; b = 0; s = 0; #10;
//        a = 0; b = 1; s = 0; #10;
//        a = 1; b = 0; s = 0; #10;
//        a = 1; b = 1; s = 0; #10;
        
//        // s = 1
//        a = 0; b = 0; s = 1; #10;
//        a = 0; b = 1; s = 1; #10;
//        a = 1; b = 0; s = 1; #10;
//        a = 1; b = 1; s = 1; #10;

//        $finish;
//    end
    
    
endmodule
