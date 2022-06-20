module EFF32 
    (   input wire en,
        input wire clk,
        input wire [31:0] D,
        output reg [31:0] Q);
    
	always @ (posedge clk) 
        begin
            if(en)
                Q <= D;
	    end
endmodule