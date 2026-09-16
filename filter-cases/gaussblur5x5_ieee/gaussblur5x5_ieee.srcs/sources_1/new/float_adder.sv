`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// float num adder - ieee format
// 
//////

module float_adder (
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
    logic [7:0] ea, eb, fin_e, diff_e;
    logic [24:0] ma, mb, shifted_m, aligned_ma, aligned_mb;
    logic [25:0] sum_m; //overflow bit - expected bit - 23...0
    //mantissa is 22:0, sum_m is 25:0 -> 'cut' sum_m before reconstruct
    
     //break numbers to Sign - Exponent - Mantissa
    //S 31 - E 30-23 - M 22-0
    assign sa = a[31];
    assign sb = b[31];
    assign ea = a[30:23];
    assign eb = b[30:23];
    
    // if e=0 -> M = 25bit 0s
    // if e !=0 -> create M as 1.M | 01m...       
    assign ma = (ea == 8'd0) ? 25'b0 : {2'b01, a[22:0]};
    assign mb = (eb == 8'd0) ? 25'b0 : {2'b01, b[22:0]};
    
    //calculations-combinational logic
    always_comb begin
        // compare expoents & align
        // find biggest -> shift smallest-M to the right for diff_e positions 
        // numbers are aligned
        // set fin_e as the e of the biggest
        if (ea >= eb) begin //mb smallest
            diff_e = ea - eb; 
            shifted_m = (diff_e > 8'd25) ? 25'd0 : (mb >> diff_e);
            aligned_ma = ma;
            aligned_mb = shifted_m;
            fin_e = ea;
        end 
        else begin //ma smallest
            diff_e = eb - ea;
            shifted_m = (diff_e > 8'd25) ? 25'd0 : (ma >> diff_e);
            aligned_ma = shifted_m;
            aligned_mb = mb;
            fin_e = eb;
        end

        //do calc based on signs
        if (sa == sb) begin //if same signs -> normal add
            sum_m = aligned_ma + aligned_mb;
            fin_s = sa;
        end 
        // if different signs -> find smaller/bigger mantissa
        // substract smaller M from the other
        // sign comes from the num with biggest val
        else if (aligned_ma >= aligned_mb) begin
            sum_m = aligned_ma - aligned_mb;
            fin_s = sa;
        end 
        else begin
            sum_m = aligned_mb - aligned_ma;
            fin_s = sb;
        end
    end
    
    logic [4:0] index;
    logic found;
    logic [4:0] shift;
    logic [25:0] shifted_sum_m;
                   
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            result <= 32'b0;
            valid_out <= 1'b0;
        end 
        else if (valid_in) begin
            // special cases (0)
            if (a[30:0] == 31'b0) begin //without the sign
                result <= b;
            end 
            else if (b[30:0] == 31'b0) begin //without the sign
                result <= a;
            end 
            else if (sum_m[24:0] == 25'b0) begin // vals are cancelled out
                result <= 32'b0;
            end 
            //else begin
            // sum_m[25]=1 - unreachable based on m struct - but just to be sure
            else if (sum_m[25]) begin
                result <= {fin_s, fin_e + 8'd2, sum_m[24:2]}; //add 2 for overflow - keep 23 MSB of M without [25]
            end
            // sum_m[24]=1 - addition-overflow case - increase E+1
            else if (sum_m[24]) begin
                result <= {fin_s, fin_e + 8'd1, sum_m[23:1]}; //add 1 for overflow - keep 23 MSB of M without [25, 24]
            end
            // sum_m[23]=1 - already fixed if overlow in prev cases - no exponent change
            else if (sum_m[23]) begin
                result <= {fin_s, fin_e, sum_m[22:0]}; //keep 23 MSB of M without [25, 24, 23]
            end
            //slide left k pos (until find 1) -decrease E-k
            // find where 1 is for the rest span of the sum_m
            else if (sum_m[22] && (fin_e >= 8'd1)) begin
                result <= {fin_s, fin_e - 8'd1, sum_m[21:0], 1'b0};
            end 
            else if (sum_m[21] && (fin_e >= 8'd2)) begin
                result <= {fin_s, fin_e - 8'd2, sum_m[20:0], 2'b0};
            end 
            else if (sum_m[20] && (fin_e >= 8'd3)) begin
                result <= {fin_s, fin_e - 8'd3, sum_m[19:0], 3'b0};
            end 
            else if (sum_m[19] && (fin_e >= 8'd4)) begin
                result <= {fin_s, fin_e - 8'd4, sum_m[18:0], 4'b0};
            end 
            else if (sum_m[18] && (fin_e >= 8'd5)) begin
                result <= {fin_s, fin_e - 8'd5, sum_m[17:0], 5'b0};
            end 
            else if (sum_m[17] && (fin_e >= 8'd6)) begin
                result <= {fin_s, fin_e - 8'd6, sum_m[16:0], 6'b0};
            end 
            else if (sum_m[16] && (fin_e >= 8'd7)) begin
                result <= {fin_s, fin_e - 8'd7, sum_m[15:0], 7'b0};
            end
            else if (sum_m[15] && (fin_e >= 8'd8)) begin
                result <= {fin_s, fin_e - 8'd8, sum_m[14:0], 8'b0};
            end
            else if (sum_m[14] && (fin_e >= 8'd9)) begin
                result <= {fin_s, fin_e - 8'd9, sum_m[13:0], 9'b0};
            end
            else if (sum_m[13] && (fin_e >= 8'd10)) begin
                result <= {fin_s, fin_e - 8'd10, sum_m[12:0], 10'b0};
            end
            else if (sum_m[12] && (fin_e >= 8'd11)) begin
                result <= {fin_s, fin_e - 8'd11, sum_m[11:0], 11'b0};
            end
            else if (sum_m[11] && (fin_e >= 8'd12)) begin
                result <= {fin_s, fin_e - 8'd12, sum_m[10:0], 12'b0};
            end
            else if (sum_m[10] && (fin_e >= 8'd13)) begin
                result <= {fin_s, fin_e - 8'd13, sum_m[9:0], 13'b0};
            end
            else if (sum_m[9] && (fin_e >= 8'd14)) begin
                result <= {fin_s, fin_e - 8'd14, sum_m[8:0], 14'b0};
            end
            else if (sum_m[8] && (fin_e >= 8'd15)) begin
                result <= {fin_s, fin_e - 8'd15, sum_m[7:0], 15'b0};
            end
            else if (sum_m[7] && (fin_e >= 8'd16)) begin
                result <= {fin_s, fin_e - 8'd16, sum_m[6:0], 16'b0};
            end 
            else if (sum_m[6] && (fin_e >= 8'd17)) begin
                result <= {fin_s, fin_e - 8'd17, sum_m[5:0], 17'b0};
            end
            else if (sum_m[5] && (fin_e >= 8'd18)) begin
                result <= {fin_s, fin_e - 8'd18, sum_m[4:0], 18'b0};
            end
            else if (sum_m[4] && (fin_e >= 8'd19)) begin
                result <= {fin_s, fin_e - 8'd19, sum_m[3:0], 19'b0};
            end
            else if (sum_m[3] && (fin_e >= 8'd20)) begin
                result <= {fin_s, fin_e - 8'd20, sum_m[2:0], 20'b0};
            end
            else if (sum_m[2] && (fin_e >= 8'd21)) begin
                result <= {fin_s, fin_e - 8'd21, sum_m[1:0], 21'b0};
            end
            else if (sum_m[1] && (fin_e >= 8'd22)) begin
                result <= {fin_s, fin_e - 8'd22, sum_m[0], 22'b0};
            end
            else if (sum_m[0] && (fin_e >= 8'd23)) begin
                result <= {fin_s, fin_e - 8'd23, 23'b0};
            end
            else begin
                result <= 32'b0;
            end

            valid_out <= 1'b1;
        end 
        else begin
            valid_out <= 1'b0;
        end
    end

endmodule