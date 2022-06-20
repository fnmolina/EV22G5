module FF32 
    (   input wire clk,
        input wire [31:0] D,
        output reg [31:0] Q);

	always @ (posedge clk) 
        begin
            Q <= D;
        end
endmodule