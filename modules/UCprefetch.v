module UCprefetch
    (   input wire      clk,
        input wire      TreadOperand,
        input wire      TwriteExecute,
        input [5:0]     operandAbus,
        input [5:0]     operandBbus,
        input [5:0]     executeCbus,
        output reg      hold_registers); 


//In case the instruction in execute stage writes over a register, analize conflicts. 
always@ (negedge clk) 
    begin 
        if(TwriteExecute and TreadOperand)      
        begin
                    if((operandAbus == executeCbus) or (operandBbus == executeCbus))  hold_registers <= 1;
                    else    hold_registers <= 0;
        end
    end 
endmodule 