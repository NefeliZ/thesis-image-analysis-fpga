`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// blur box filter with 5x5 window - testbench
//////

module tb_blurF_5x5;

    localparam DATA_WIDTH = 8;
    
    logic clk;
    logic reset;
    logic valid_in;
    logic [DATA_WIDTH-1:0] window [0:4][0:4];
    
    logic valid_out;
    logic [7:0] pixel_out;

    // instantiation uut
    blurF_5x5 #(
    .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .window(window),
        .valid_out(valid_out),
        .pixel_out(pixel_out)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    //vars & paths for files
    int file_in, file_out;
    int status;
    logic [7:0] p [0:24]; // each line has 25 vals (full window)
    
    //for debugging
    int read_count  = 0; //count read pixels
    int write_count = 0; // count written pixels
    
    parameter string path = "C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/";
    parameter string FILE_IN  = {path, "bin_vals_5x5.txt"};
    parameter string FILE_OUT = {path, "verilog_out_blur_5x5.txt"};
        
    initial begin
    
        $display("--------------------------------------------------");
        $display("Sobel 1 window 3x3 testbench - img file input ");
        $display("--------------------------------------------------");
        
        file_in  = $fopen(FILE_IN, "r");
        file_out = $fopen(FILE_OUT, "w");

        if (file_in == 0) 
        begin
            $display("error. file not opened");
            $finish;
        end

        // reset
        reset    = 0;
        valid_in = 0;
        #20 
        reset = 1;

        //read line -> window
        while (!$feof(file_in)) 
        begin
            //scan vals from file
            status = $fscanf(file_in, "%b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b\n", 
                 p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], 
                 p[10], p[11], p[12], p[13], p[14], p[15], p[16], p[17], p[18], p[19], 
                 p[20], p[21], p[22], p[23], p[24]);

            if (status == 25) 
            begin
                read_count++; // calc read
                @(posedge clk);
                #1;
                valid_in = 1'b1; //took input
                
                //assign vals to window
                window[0][0] = p[0];  window[0][1] = p[1];  window[0][2] = p[2];  window[0][3] = p[3];  window[0][4] = p[4];
                window[1][0] = p[5];  window[1][1] = p[6];  window[1][2] = p[7];  window[1][3] = p[8];  window[1][4] = p[9];
                window[2][0] = p[10]; window[2][1] = p[11]; window[2][2] = p[12]; window[2][3] = p[13]; window[2][4] = p[14];
                window[3][0] = p[15]; window[3][1] = p[16]; window[3][2] = p[17]; window[3][3] = p[18]; window[3][4] = p[19];
                window[4][0] = p[20]; window[4][1] = p[21]; window[4][2] = p[22]; window[4][3] = p[23]; window[4][4] = p[24];
            end
        end

        // when file is finished
        @(posedge clk);
        #1;
        valid_in = 1'b0;

        #100; // some delay
        
        //flush data from ram to file 
        $fflush(file_out);
        
        $fclose(file_in);
        $fclose(file_out);
        $display("-----done");
        $display("read: %0d", read_count);
        $display("written: %0d", write_count);
        $finish;
    end

    //save to file
    always @(posedge clk) 
    begin
        if (valid_out) begin
            $fwrite(file_out, "%d\n", pixel_out);
            write_count++;
        end
    end

endmodule