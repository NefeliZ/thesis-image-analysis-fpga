`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gaussin blur filter with 3x3 window - integers - shifts
//////

module gaussblur3x3_int_shift #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
    
    //pixel inputs 
    input  logic [DATA_WIDTH-1:0] p00, p01, p02,
    input  logic [DATA_WIDTH-1:0] p10, p11, p12,
    input  logic [DATA_WIDTH-1:0] p20, p21, p22,
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out // center pixel val - G
);
    
    // assing pixel vals to window
    logic [DATA_WIDTH-1:0] window [0:2][0:2];
    
    assign window[0][0] = p00;  assign window[0][1] = p01;  assign window[0][2] = p02;
    assign window[1][0] = p10;  assign window[1][1] = p11;  assign window[1][2] = p12;
    assign window[2][0] = p20;  assign window[2][1] = p21;  assign window[2][2] = p22;
    
    //gaussian blur calculations
    logic [11:0] g_sum;

    always_comb begin
        // K: 1/16 * [1 2 1 | 2 4 2 | 1 2 1]
        //-> 1*img00, 2*img01, 1*img02 , 2*img10, 4*img11, 2*img12 , 1*img20, 2*img21, 1*img22
        //extra 'paddign'(0s at the sign) to avoid error when shifting
        g_sum = {4'b0, window[0][0]} + ({4'b0, window[0][1]} << 1) + {4'b0, window[0][2]}
                + ({4'b0, window[1][0]} << 1) + ({4'b0, window[1][1]} << 2) + ({4'b0, window[1][2]} << 1)
                + {4'b0, window[2][0]} + ({4'b0, window[2][1]} << 1) + {4'b0, window[2][2]};
    end

    //make output logic
    always_ff @(posedge clk or negedge reset) begin //activate at posedge or at reset
        if (!reset) begin //if reset=1 -> output=0 (reset)
            pixel_out <= '0;
            valid_out <= 1'b0;
        end 
        else begin
            //fix alignment problem - in and out in synch to wait for pixelout
            valid_out <= valid_in;
            if (valid_in) begin //if it took val
                // keep bits [11:4] = g_sum >> 4 = 1/16
                pixel_out <= g_sum[11:4];
                //no saturation case needed
                // factors sum up to 16 so when div by 16 =1
                // for vals <=255 it wont saturate
            end 
            else begin //else it didnt make val
                valid_out <= 1'b0; 
            end
       end
    end

endmodule