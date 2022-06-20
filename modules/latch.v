module latch16
    (   input wire [15:0] D,
		output reg [15:0] Q);

	always @ (D) 
        begin
            Q <= D;
	    end
endmodule
