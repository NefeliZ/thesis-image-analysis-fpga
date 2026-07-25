`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// FSM counter me overflow
//////


module fsm_counter #(
    parameter counter_width = 4 //changable width of counter
)(
    input  logic clk,
    input  logic reset,
    input  logic act,
    input  logic up_down,
    output logic [counter_width-1:0] count,
    output logic ovflw
);

    // define states
    localparam IDLE  = 4'b0001;
    localparam CNTUP = 4'b0010;
    localparam CNTDN = 4'b0100;
    localparam OVFLW = 4'b1000;

    // state vars
    logic [3:0] state, next_state;

    //calc next state
    always_comb begin
        case (state)
            IDLE: begin
                if (act) begin
                    if (up_down) next_state = CNTUP;
                    else          next_state = CNTDN;
                end else begin
                    next_state = IDLE;
                end
            end

            CNTUP: begin
                if (act) begin
                    if (up_down) begin
                        // if reach max value -> overflow
                        if (count == (1 << counter_width) - 1)
                            next_state = OVFLW;
                        else
                            next_state = CNTUP;
                    end else begin
                        next_state = CNTDN;
                    end
                end else begin
                    next_state = IDLE;
                end
            end

            CNTDN: begin
                if (act) begin
                    if (up_down) begin
                        next_state = CNTUP;
                    end else begin
                        // if coutndown reeach 0 -> overflow
                        if (count == 'b0)
                            next_state = OVFLW;
                        else
                            next_state = CNTDN;
                    end
                end else begin
                    next_state = IDLE;
                end
            end

            OVFLW: begin
                next_state = OVFLW; // stay in overflow
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // update state registers & counter
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    //update counter
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            count <= 'b0;
        end else begin
            if (state == CNTUP)
                count <= count + 1'b1;
            else if (state == CNTDN)
                count <= count - 1'b1;
        end
    end

    //output logic
    assign ovflw = (state == OVFLW) ? 1'b1 : 1'b0;

endmodule
