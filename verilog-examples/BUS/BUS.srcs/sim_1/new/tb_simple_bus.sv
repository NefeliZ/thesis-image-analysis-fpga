`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple bus: modports&interface - testbench(t0p module)
//////

module tb_system_top;

    logic t_clk;

    //clock
    initial begin
        t_clk = 1'b0;
        forever #5 t_clk = ~t_clk;
    end

    //interface instance
    simple_bus bus ( .clk(t_clk) );

    //module instance - connect through bus
    memory mem ( .bus(bus.slave) ); 
    cpu    proc( .bus(bus.master) );

    //test
    initial begin
        $display("----------------");
        $monitor("%0dns\t    %b    |     %b      |  %h", $time, bus.req, bus.gnt, bus.addr);

        #12;
        //master request
        bus.req  = 1'b1;
        bus.addr = 8'hA4;

        #20;
        //cancel request
        bus.req  = 1'b0;

        #20;
        $finish;
    end

endmodule