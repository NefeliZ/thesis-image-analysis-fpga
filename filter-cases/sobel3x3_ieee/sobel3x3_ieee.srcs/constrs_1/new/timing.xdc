create_clock -add -name clk -period 13.000  [get_ports {clk}];

# fix errors: missing input delay on pixel_in[0]....
set_input_delay -clock clk 0.000 [get_ports {pixel_in[*] valid_in}];
set_output_delay -clock clk 0.000 [get_ports {pixel_out[*] valid_out}];

set_false_path -from [get_ports reset];