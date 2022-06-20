module shifter (
    input [1:0] op,
    input [15:0] c,
    output reg [15:0] c_out
);
    always @(op or c) begin
        case (op)
            2'b00   :   c_out <= c;
            2'b01   :   c_out <= c<<1;
            2'b10   :   c_out <= c>>1;
            default :   c_out <= c;
        endcase
    end
endmodule