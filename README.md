# Image analysis with FPGA (Verilog)

Repository for undergrad thesis.

## Current subdirectories
* image_proccess: 
    * make input file for verilog code. binary values of gray test image, in proper format
    * take verilog output -> recreate image & compare with python filtered image
    * custom filters in python
    * filtered image comparison
* filter_cases
    * different image filters with different window sizes
    * Systemverilog projects with different cases (shifts, adders/multipliers)
    * results & metrics
* examples in verilog: .xpr project, sources and testbenches
    * basic gates
    * multiplexers (2-to-1, 4-to-1)
    * Decoders
    * Flip-Flop
    * Counter
    * FSM
    * image flters tests


## Versions

### Python v. 3.13.0
setup_env.py: installs all basic packages


### Currently using **Xilinx Vivado 2025.2**
For vivado projects, file structure of sources & TBs should allow to run locally

