module elatch16
    (   input en,
	    input wire [15:0] D,
		output reg [15:0] Q);

	always @ (en or D) 
        begin
            if(en)
                Q <= D;
	    end
endmodule