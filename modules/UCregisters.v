module UCregisters 
    (   input [32:0] MIR_Operand,
		  input [32:0] MIR_Execute,
		  output reg [32:0]	UC_MIR,
        output reg UC_enable); 


//In case the instruction in execute stage writes over a register, analize conflicts. 
always@ (MIR_Operand[7] or MIR_Execute[8] or MIR_Operand[5] or MIR_Execute[6]) 
    begin 
        if(MIR_Execute[8] && MIR_Operand[7])  //Si leo y escribo un registro, me fijo si es el mismo    
        begin
                    if((MIR_Operand[4:0] == MIR_Execute[17:12]) || (MIR_Operand[23:18] == MIR_Execute[17:12]))
							begin 
								UC_enable <= 0;
								UC_MIR	<= 33'b000000000100011100011010000000000;
							end 
							
                    else
							begin
								UC_enable <= 1;
								UC_MIR <=	MIR_Operand;
							end
			end
		  if(MIR_Operand[5] && MIR_Execute[6])     //Si leo y escribo WR, me fijo si es el mismo  
			begin
			  if((MIR_Operand[4:0] == MIR_Execute[17:12]) || (MIR_Operand[23:18] == MIR_Execute[17:12]))
				begin 
					UC_enable <= 0;
					UC_MIR	<= 33'b000000000100011100011010000000000;
				end 
				
			  else
				begin
					UC_enable <= 1;
					UC_MIR <=	MIR_Operand;
				end
			end
				
			//Sino esta todo bien
			else
				begin
					UC_enable <= 1;
					UC_MIR <=	MIR_Operand;
				end
    end 
endmodule 