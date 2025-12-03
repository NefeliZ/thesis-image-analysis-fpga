module stimulus;

	// Inputs
	reg i1;
	reg i2;
	reg i3;

	// Outputs
	wire gateOutput;

	// Instantiate the Unit Under Test (UUT)
	threeInputOrGate uut (
		.i1(i1), 
		.i2(i2), 
		.i3(i3), 
		.gateOutput(gateOutput)
	);

	initial begin
		// Initialize Inputs
		i1 = 0;
		i2 = 0;
		i3 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		#50 i1 =1;
		#50 i1=0;
		#60 i3=1;
	end
      
		initial begin
			$monitor("output=%d,i1=%d,i2=%d,i3=%d\n", gateOutput,i1,i2,i3);
		end
endmodule
