module mux (
    input sel,
    input [15:0] D0,
    input [15:0] D1,
    output reg [15:0] Q
);
    always @(D0 or D1 or sel) begin
        if (sel) begin
            Q <= D1;
        end else begin
            Q <= D0;
        end
    end  
endmodule