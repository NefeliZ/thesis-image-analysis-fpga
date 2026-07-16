`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// FSM 101 sequence detector
//////


module fsm_101(
    input wire clk,
    input wire reset,
    input wire in,
    output reg out
    );
    
    //define states
    localparam s_0 = 2'b00, s_1 = 2'b01, s_10 = 2'b10;

    reg [1:0] curr_state, next_state;
    
    // update curr state
    always @(posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            curr_state <= s_0;
        end else begin
            curr_state <= next_state; //change state with clock
        end
    end
    
    // decide next state
    always @(*) begin
        //default for safety
        next_state = curr_state;
        out = 1'b0;

        case (curr_state)
            s_0: begin //if s0 and in=1 -> next=s1 else s0
                if (in == 1'b1) 
                    next_state = s_1;
                else 
                    next_state = s_0;
            end

            s_1: begin //if s1 and in=0 -> next=s10 else s1 (curr)
                if (in == 1'b0) 
                    next_state = s_10;
                else 
                    next_state = s_1;
            end

            s_10: begin //if s10 and in=1 -> out=1 && next=s1 (start next round) 
                if (in == 1'b1) begin
                    next_state = s_1; 
                    out = 1'b1;
                end 
                else begin //if s10 and in=0 -> next=s0 - sequenxe is wrong
                    next_state = s_0; 
                end
            end

            default: begin
                next_state = s_0;
                out = 1'b0;
            end
        endcase
    end
    
endmodule
