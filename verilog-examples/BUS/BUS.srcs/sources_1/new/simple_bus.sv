`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple bus: modports&interface
//////

interface simple_bus(input logic clk);
    logic req;
    logic gnt;
    logic [7:0] addr;
    logic [7:0] data;

    //master directions
    modport master (
        output req, addr,
        input  gnt, clk,
        inout  data
    );

    //slave directions
    modport slave (
        input  req, addr, clk,
        output gnt,
        inout  data
    );
endinterface

//slave module
module memory (
    simple_bus.slave bus //slave modport
);
    //when in=request -> out=grant
    always_ff @(posedge bus.clk) begin
        bus.gnt <= bus.req;
    end
endmodule

//master module
module cpu (
    simple_bus.master bus //master modport
);
    //sends request (output)
    initial begin
        bus.req  = 1'b0;
        bus.addr = 8'h00;
    end
endmodule