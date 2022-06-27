module UCmemory 
    (   input wire  clk,
        input wire  MRdecode,
        input wire  MWoperand,
        output reg  hold_memory); 


always@ (negedge clk) 
    begin 
        if(MRdecode and MWoperand)  hold_memory <= 1;
        else    hold_memory <= 0;
    end 

endmodule 