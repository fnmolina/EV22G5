module alu (
    input [3:0] operation,
    input [15:0] reg_a, reg_b,
    output reg signed [15:0] c_out;
    output reg signed [31:0] c_mul_out;
    output reg [3:0] CCR
);
    parameter   nop_a   = 4'b0000;
                nop_b   = 4'b0001;
                not_a   = 4'b0010;
                op_and  = 4'b0011;
                op_or   = 4'b0100;
                op_xor  = 4'b0101;
                op_add  = 4'b0110;
                op_sub  = 4'b0111;
                op_mul  = 4'b1000;
                op_div  = 4'b1001;
                op_mod  = 4'b1010;
                clr_c   = 4'b1011;
                set_c   = 4'b1100;

always @(reg_a, reg_b, operation) begin
    CCR = 0;
    case (operation)
        nop_a:  c_out <= reg_a;
        nop_b:  c_out <= reg_b;
        not_a:  c_out <= ~reg_a;
        op_and: c_out <= reg_a & reg_b;
        op_or:  c_out <= reg_a | reg_b;
        op_xor: c_out <= reg_a ^ reg_b;
        //op_add: begin
            
        //end
        //op_sub: begin
            
        //end
        op_mul: c_mul_out <= reg_a * reg_b;
        //op_div:
        op_mod: c_out <= reg_a % reg_b;
        //clr_c:
        //set_c:  
        default: c <= 0; 
    endcase
    if (c_out == 0)
        CCR = CCR | 4'b0100;
    else if (c_out < 0)
        CCR = CCR | 4'b1000;
end

endmodule