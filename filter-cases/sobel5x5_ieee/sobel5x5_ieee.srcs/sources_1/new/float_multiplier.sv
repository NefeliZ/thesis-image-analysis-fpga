`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// float num multiplier - ieee format
// 
//////

module float_multiplier (
    input logic clk,
    input logic reset,
    input logic valid_in,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] result,
    output logic valid_out
);
    
    //keep S,E,M for input numbers and fin result
    // vars for align, over/undrflow
    logic sa, sb, fin_s;
    logic [7:0] ea, eb;
    logic [8:0] fin_e; // bigger to keep overflow of addition
    logic [23:0] ma, mb; //mantissa is 22:0. 24bit to have overflowbit
    logic [47:0] prod_m; //48bit for mantissa product
    
    //break numbers to Sign - Exponent - Mantissa
    //S 31 - E 30-23 - M 22-0
    assign sa = a[31];
    assign sb = b[31];
    assign ea = a[30:23];
    assign eb = b[30:23];
    
    // if e=0 -> M = 24bit 0s
    // if e !=0 -> create M as 1.M | 1m...       
    assign ma = (ea == 0) ? 24'b0 : {1'b1, a[22:0]};
    assign mb = (eb == 0) ? 24'b0 : {1'b1, b[22:0]};
    
    //calculations
    always_comb begin
        //sign: XOR gate => same=0=positive, diff=1=negative
        fin_s = sa ^ sb;
        
        //exponents: add E - bias (127)
        fin_e = ea + eb -9'd127;
        
        //Mantissa: multiply
        prod_m = ma * mb;
    end
    
    logic [8:0] increased_e;
    
    // output logic & cases - fixes   
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            result <= 32'b0;
            valid_out <= 1'b0;
        end 
        else if (valid_in) begin
        //special cases
            if (a == 32'b0 || b == 32'b0) begin
                result <= 32'b0;
            end
            else begin
                //overflow fix: shift M 1pos to the right(keep 46:24) and increase E+1
                if (prod_m[47]) begin
                    increased_e = (fin_e + 9'd1);
                    result <= {fin_s, increased_e[7:0], prod_m[46:24]};
                end
                else begin
                    result <= {fin_s, fin_e[7:0], prod_m[45:23]};
                end
            end
            valid_out <= 1'b1;
        end
        else begin
            valid_out <= 1'b0;
        end
    end
endmodule