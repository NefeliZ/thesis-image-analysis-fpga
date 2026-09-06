`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// blur filter with 2 windows 3x3 - testbench
//////

module tb_blur_3x3;

    localparam DATA_WIDTH = 8;
    
    logic clk;
    logic reset;
    logic valid_in;
    logic [DATA_WIDTH-1:0] grid [0:2][0:3];
    
    logic valid_out;
    logic [7:0] pixel_out_0;
    logic [7:0] pixel_out_1;

    // instantiation uut
    blur_3x3#(
    .DATA_WIDTH(DATA_WIDTH)
    )uut(
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
    
    //2 windows => 3rows & 4cols => 12 pixels -> 3x4
    .grid(grid), 
    
    .valid_out(valid_out),
    .pixel_out_0(pixel_out_0), // 1st window
    .pixel_out_1(pixel_out_1)  //2nd win
);

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    //vars & paths for files
    int file_in, file_out;
    int status;
    logic [7:0] p [0:11]; // each line has 12 vals (2 windows 1 grid)
    
    //for debugging
    int read_count  = 0; //count read pixels
    int write_count = 0; // count written pixels
    
    parameter string path = "C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/";
    parameter string FILE_IN  = {path, "bin_vals_2win_3x3.txt"};
    parameter string FILE_OUT = {path, "verilog_out_blur_2win_3x3.txt"};
        
    initial begin
    
        $display("--------------------------------------------------");
        $display("Blur 2 window 3x3 testbench - img file input ");
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
            status = $fscanf(file_in, "%b %b %b %b %b %b %b %b %b %b %b %b\n", 
                 p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], 
                 p[10], p[11]);

            if (status == 12) 
            begin
                read_count++; // calc read
                @(posedge clk);
                #1;
                valid_in = 1'b1; //took input
                
                //assign vals to grid
                grid[0][0] = p[0];  grid[0][1] = p[1];  grid[0][2] = p[2];  grid[0][3] = p[3];
                grid[1][0] = p[4];  grid[1][1] = p[5];  grid[1][2] = p[6];  grid[1][3] = p[7];
                grid[2][0] = p[8];  grid[2][1] = p[9];  grid[2][2] = p[10]; grid[2][3] = p[11];
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
           $fwrite(file_out, "%d\n", pixel_out_0);
            $fwrite(file_out, "%d\n", pixel_out_1);
            write_count += 2;
        end
    end

endmodule