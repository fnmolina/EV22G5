module pc (
    input enable,
    input clk,
    input [23:0] IR,    //Instruction register = set de instrucciones
    input [3:0] CCR,    // CCR = CY
    output reg [11:0] pc_output
    );
    reg [11:0] pc_aux;
    reg [23:0] temp;
    reg start;
    reg hold;
    initial begin
        pc_output   =   0;
        pc_aux      =   0;
        start       =   0;
        hold        =   0;
    end
    
    always @(posedge clk) begin
        if (en) begin
            if (start) begin
                temp = IR >> 12;
                case (temp)
                    12'b100000000100: pc_output <= pc_aux + 1;  // RET
                    12'b100000000000: pc_output <= IR;          // JMP X
                    12'b100000000001: begin //JZE X -> IF W=0 THEN PC=X
                        if (hold) begin
                            if (CCR & 4'b0100) begin
                                pc_output <= IR;
                            end else begin
                                pc_output <= pc_output + 1; 
                            end
                            hold = 0;
                        end else begin
                            hold = 1;
                        end
                    end 
                    12'b100000000010: begin //JNE X -> IF W15=0 THEN PC=X
                        if (hold) begin
                            if (CCR & 4'b1000) begin
                                pc_output <= IR;
                            end else begin
                                pc_output <= pc_output + 1;
                            end
                            hold = 0;
                        end else begin
                            hold = 1;
                        end
                    end
                    12'b100000000011: begin //JCY X -> IF CY THEN PC=X
                        if (hold) begin
                            if (CCR & 4'b0001) begin
                                pc_output <= IR;
                            end else begin
                                pc_output <= pc_output + 1;
                            end
                            hold = 0;
                        end else begin
                            hold = 1;
                        end
                    end
                    12'b100000000101: begin //BSR S
                        pc_aux = pc_output;
                        pc_output = pc_output + IR;
                    end
                    default: pc_output <= pc_output + 1;
                endcase
            end
            else
                start = 1;
        end
    end
endmodule