module EFF24 
    (   input en,
        input clk,
        input [23:0] D,
        output reg [23:0] Q);
    
	always @ (posedge clk) 
        begin
            if(en)
                Q <= D;
        end
endmodule