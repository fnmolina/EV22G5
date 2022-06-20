module mux_k (
    input sel,
    input [15:0] D0,
    input [15:0] K,
    output reg [15:0] Q
);
    always @(D0 or K or sel) begin
        if (sel) begin
            Q <= K & 16'h01ff;
        end else begin
            Q <= D0;
        end
    end
endmodule