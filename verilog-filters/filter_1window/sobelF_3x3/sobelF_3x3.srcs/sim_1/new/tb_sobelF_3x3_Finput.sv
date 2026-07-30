`timescale 1ns / 1ps

// sobel filter with 3x3 window - testbench with input file 
// (from python preprocess)

module tb_sobelF_3x3_Finput;

    localparam DATA_WIDTH = 8;
    
    logic clk;
    logic reset;
    logic valid_in;
    logic [DATA_WIDTH-1:0] window [0:2][0:2];
    
    logic valid_out;
    logic [7:0] pixel_out;

    // instantiation uut
    sobelF_3x3 #(
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
    logic [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8; //each line has 9 vals (full window)
    
    //for debugging
    int read_count  = 0; //count read pixels
    int write_count = 0; // count written pixels
    
    parameter string path = "./img_process/files";
    parameter string FILE_IN  = {path, "bin_vals_3x3.txt"};
    parameter string FILE_OUT = {path, "verilog_out.txt"};
        
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
            status = $fscanf(file_in, "%b %b %b %b %b %b %b %b %b\n",p0, p1, p2, p3, p4, p5, p6, p7, p8);

            if (status == 9) 
            begin
                read_count++; // calc read
                @(posedge clk);
                #1;
                valid_in = 1'b1; //took input
                
                //assign vals to window
                window[0][0] = p0; window[0][1] = p1; window[0][2] = p2;
                window[1][0] = p3; window[1][1] = p4; window[1][2] = p5;
                window[2][0] = p6; window[2][1] = p7; window[2][2] = p8;
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
