module VGA_driver (
	input clk_25MHz,
	output reg[15:0] horiz_count,
	output reg[15:0] vert_count
);

	reg enable_Vert;

	initial begin
		enable_Vert = 0;
		horiz_count = 0;
		vert_count = 0;
	end

	always@ (posedge clk_25MHz) begin
		if (horiz_count < 799) begin
			horiz_count <= horiz_count + 1;
			enable_Vert <= 0; //set low Vertical counter
		end
		else begin //triggered once
			horiz_count <= 0; //reset counter
			enable_Vert <= 1; //enable as top was reached
		end
		
		if (enable_Vert == 1'b1) begin
			if (vert_count < 524)
			//keep counting
				vert_count <= vert_count + 1;
			else vert_count <= 0; //reset counter
		end
	end
endmodule 