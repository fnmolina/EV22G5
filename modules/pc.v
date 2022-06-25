module pc (
    input enable,
    input clk,
    input [15:0] IR,
    input [3:0] CCR,
    output reg [11:0] pc_output
);

    reg [11:0] pc_aux;
    reg [15:0] temp;
    reg start;
    reg hold;
    initial begin
        pc_output   =   0;
        pc_aux      =   0;
        start       =   0;
        hold        =   0;
    end
    
    always @(posedge clk) begin
        
    end
endmodule

module PC_v (input en, 
				 input clk,
				 input [15:0] IR,
				 input [3:0] CCR,
				 output reg [11:0] PC);
	reg [11:0] PC_;
	reg [15:0] temp;
	reg start;
	reg hold;
	initial begin
		PC = 0;
		PC_ = 0;
		start = 0;
		hold = 0;
	end
	always@ (posedge clk) begin //always@ (negedge clk) begin
		if (en) begin
			if (start) begin
				temp = IR >> 12;
				case (temp)
					4'b0000 : begin
						temp = IR >> 8;
						case (temp)
							4'b1101 : PC <= PC_ + 1; //RET
							default : PC <= PC + 1;
						endcase
					end
					4'b1000 : PC <= IR; //JMP X
					4'b1001 : begin //JZE X
						if (hold) begin
							if (CCR & 4'b0100)
								PC <= IR;
							else
								PC <= PC + 1;
							hold = 0;
						end
						else
							hold = 1;
					end
					4'b1010 :begin //JNE X
						if (hold) begin
							if (CCR & 4'b1000)
								PC <= IR;
							else
								PC <= PC + 1;
							hold = 0;
						end
						else
							hold = 1;
					end
					4'b1011 : begin //JCY X
						if (hold) begin
							if (CCR & 4'b0001)
								PC <= IR;
							else
								PC <= PC + 1;
							hold = 0;
						end
						else
							hold = 1;
					end
					4'b1110 : begin //BSR S
						PC_ = PC;
						PC <= PC + IR;
					end
					default : PC <= PC + 1; //MER W,Y //MEW Y,W
				endcase
			end
			else
				start = 1;
		end
	end
endmodule