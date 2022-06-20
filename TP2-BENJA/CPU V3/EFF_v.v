module EFF_v (input en,
				  input clk,
				  input [32:0] D,
				  output reg [32:0] Q);
	always@ (posedge clk) begin
		if (en)
			Q <= D;
	end
endmodule