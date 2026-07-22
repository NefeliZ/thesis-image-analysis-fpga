`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gray code to binary - testbench
//////

module tb_gray2bin;

    //test size change
    localparam test_size = 4;

    logic [test_size-1:0] t_gray;
    logic [test_size-1:0] t_bin;

    gray2bin #(
        .size(test_size)
    ) uut (
        .gray(t_gray),
        .bin(t_bin)
    );

    initial begin
        $display("----------------");
        $monitor("%0dns\t     %b      |     %b", $time, t_gray, t_bin);

        t_gray = 4'b0000; #10; // Gray 0000 -> Bin 0000 (0)
        t_gray = 4'b0001; #10; // Gray 0001 -> Bin 0001 (1)
        t_gray = 4'b0011; #10; // Gray 0011 -> Bin 0010 (2)
        t_gray = 4'b0010; #10; // Gray 0010 -> Bin 0011 (3)
        t_gray = 4'b0110; #10; // Gray 0110 -> Bin 0100 (4)
        t_gray = 4'b0111; #10; // Gray 0111 -> Bin 0101 (5)
        t_gray = 4'b1100; #10; // Gray 1100 -> Bin 1000 (8)
        t_gray = 4'b1000; #10; // Gray 1000 -> Bin 1111 (15)

        $finish;
    end

endmodule