module EFF32 
    (   input wire en,
        input wire clk,
        input wire [32:0] D,
        output reg [32:0] Q);
    
	always @ (posedge clk) 
        begin
            if(en)
                Q <= D;
	    end
endmodule