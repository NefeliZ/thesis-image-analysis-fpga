# Design and Implementation of Spatial Image Filters on FPGA 

Repository for undergrad thesis, in SystemVerilog

## Subdirectories
* filter_cases:
    * Systemverilog projects 
    * Sobel filter, Gaussian blur, Cascaded filters (Gauss -> Sobel)
    * 3x3, 5x5 kernel sizes
    * Integer (shift-and-add) and custom binary32 floating-point single-precision (IEEE 754 format)

* img_proccess: 
    * pre-process: binary values of grayscale test image in .txt file used as input for HW filter modules
    * post-process: reconstruction of image from HW .txt output, image comparison
    * custom filter implementation in python
    * additional functions

* plots:
    plots of hardware resource metrics

* results:
    * reconstructed filtered images, image comparison plots
    * hardware resource metrics, utilization reports

* thesis-files:
    thesis document and presentation.

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


### **AMD Xilinx Vivado Design Suite 2025.2** in SystemVerilog
.xpr files and sources (testbench, modules, constraints) should allow to run locally

