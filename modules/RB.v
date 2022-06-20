module RB_v (input clk, 
				 input [5:0] WC, 
				 input [5:0] RA, 
				 input [4:0] RB, 
				 input [15:0] C,
				 output reg [15:0] A, 
				 output reg [15:0] B);
	reg [15:0] R [0:34]; //GPR+IO+W+AUX
	always@ (posedge clk) begin ///
		R[WC] <= C;
	end
	always@ (RA or RB) begin ///
		A <= R[RA];
		B <= R[RB];
	end
endmodule