`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// testbench with input file
// sobel filter with 3x3 window - ieee
//////

module tb_sobel3x3_ieee;

    localparam DATA_WIDTH = 8;
    localparam int IMG_WIDTH = 366; //CHANGE
    localparam int IMG_HEIGHT = 485;
    
    localparam int TOTAL_PIXELS = (IMG_WIDTH) * (IMG_HEIGHT); 
    localparam int EXPECTED_PIXELS = (IMG_WIDTH-2) * (IMG_HEIGHT-2); //skip padding
    // => less total pixels in output than input
    // img comes padded all around from python to do calcs only in main image & win fits exactly
        
    // vars for metrics - counters
    int cyc_count;
    int init_lat_cyc;
    int total_sim_cycles;
    bit first_pixel_seen;
    
    // clock
    localparam time CLK_PERIOD = 13ns; 
    logic clk;
    logic reset;
    
    // valid checks
    logic [DATA_WIDTH-1:0] pixel_in;
    logic [DATA_WIDTH-1:0] pixel_out;
    logic valid_in;
    logic valid_out;
    
    // var for file input
    logic [DATA_WIDTH-1:0] f_input;
    
    // instantiation uut of top module only
    top_sobel3x3_ieee #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT (IMG_HEIGHT)
    ) 
    dut_ieee(
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .pixel_out (pixel_out),
        .valid_out (valid_out)
    );
        
    // clock config
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk; 
        // F = 1/T && 1 cycle = 2 parts of square pulse up down
        // change clock sign every T/2
    end
    
    // cycle counter
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            cyc_count <= 0;
        else
            cyc_count <= cyc_count + 1;
    end

    //vars & paths for files
    int file_in, file_out;
    int status;
    
    //for debugging
    int read_count  = 0; //count read pixels
    int write_count = 0; // count written pixels
    
    parameter string path = "C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/";
    parameter string FILE_IN = {path, "smeagol_bin_vals.txt"};
    parameter string FILE_OUT = {path, "smeagol_verilog_out_sobel3x3_ieee.txt"};

    ////////
    // feed input pixels
    initial begin
    
        $display("--------------------------------------------------");
        $display("Sobel 1 window 3x3 testbench - ieee ");
        $display("--------------------------------------------------");
        
        file_in  = $fopen(FILE_IN, "r");

        if (file_in == 0) begin
            $display("error. file not opened");
            $finish;
        end

        // reset
        reset = 0;
        valid_in = 0;
        pixel_in = 0;
        #(CLK_PERIOD * 2); //wait 2 periods
        reset = 1;

        //read pixels until EOF
        while (!$feof(file_in)) begin
            @(posedge clk);
            //scan val from file
            status = $fscanf(file_in, "%b\n", f_input); // returns how many vals it read && -1 or 0 for EOF

            if (status == 1) begin
                read_count++; // calc read
                valid_in <= 1'b1; //took input
                pixel_in <= f_input; //val from file
            end
            else begin 
            valid_in <= 1'b0;
            end
        end
        
    
        //dummy cycles to get the last pixel
        repeat (3) begin
            @(posedge clk);
            valid_in <= 1'b1;
            pixel_in <= 8'd0;
        end
        
        
        // when file is finished
        @(posedge clk);
        valid_in = 1'b0;
        $fclose(file_in);
    end
    
    ////////
    // get output and save file
    initial begin              
        first_pixel_seen = 0;
        
        //file-out things
        file_out = $fopen(FILE_OUT, "w");
        
        if (file_out == 0) begin
            $display("error. OUTPUT file not opened");
            $finish;
        end
        
        // wait for system to be ready - reset=1
        wait (reset == 1'b1); 
        
        while (1) begin
            @(posedge clk); //CHANGE NEGEDGE delay to take pixel out properly
            if (valid_out) begin //wait for line buffee to fill
                if (!first_pixel_seen) begin //=> first_pixel_seen=1
                    init_lat_cyc = cyc_count; //latency
                    first_pixel_seen = 1;
                end

                $fwrite(file_out, "%d\n", pixel_out);
                write_count++;
                
                if (write_count % 500 == 0) begin
                    $display("Pixels written so far: %0d / %0d", write_count, EXPECTED_PIXELS);
                end
                
                if (write_count == EXPECTED_PIXELS) begin //if all are calced/written
                    total_sim_cycles = cyc_count;
                    break; // end loop
                end
                
            end
        end
        

        //flush data from ram to file 
        $fflush(file_out);
        $fclose(file_out);
        $display("-----done");
        $display("read: %0d", read_count);
        $display("written: %0d", write_count);
        $display("latency cycles: %0d", init_lat_cyc);
        $display("total cycles: %0d", total_sim_cycles);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule