module MIR 
    (   input wire  clk,
        input [23:0] IR, //Instruction
		output reg [23:0] indexOut,
		output reg [23:0] groupOut,
        output reg [32:0] MIR); //Microinstruction 


    reg [32:0] ROM0 [0:15];   
    reg [32:0] ROM1 [0:15];
    reg [32:0] ROM2 [0:15];
    reg [32:0] ROM3 [0:15];
    reg [32:0] ROM4 [0:15];

    reg [23:0] aux;
    reg [23:0] group;
    reg [23:0] index;

    parameter ROM0index = 24'h800000;
    parameter ROM1index = 24'h400000;
    parameter ROM2index = 24'h200000;
    parameter ROM3index = 24'h100000;
    parameter ROM4index = 24'h080000;

	initial begin       

	    ROM0[0] = 33'b000000000000000100011100000000000		//JMPX	 
	    ROM0[1] = 33'b000000000000000100011100000100000		//JZEX	
	    ROM0[2] = 33'b000000000000000100011100000100000		//JNE X	
	    ROM0[3] = 33'b000000000000000100011101000000000		//JCY X	
        ROM0[4] = 33'b000000000000000100011100000000000		//RET		
	    ROM0[5] = 33'b000000000000000100011100000000000		//BSR S	
	    ROM0[6] = 33'b000000001000000100011000000100000		//MOM Y, W
	    ROM0[7] = 33'b000000010000000100011000001000000		//MOM W, Y

		ROM1[0] = 33'b000000100100011100010000001000000			//MOK W, #K	    
		ROM1[1] = 33'b001100100100010100010000001100000			//ANK W, #K	    
		ROM1[2] = 33'b010000100100010100010000001100000			//ORK W, #K	    
		ROM1[3] = 33'b011000100100010100010011001100000			//ADK W, #K	    
		ROM1[4] = 33'b010100100100010100010011001100000			//W = W xor K	    
		ROM1[5] = 33'b011100100100010100010011001100000			//W = W - K - CY	
		ROM1[6] = 33'b100000100100010100010011001100000			//W = W * K	     
		ROM1[7] = 33'b100100100100010100010011001100000			//W = W / K	    
		ROM1[8] = 33'b101000100100010100010011001100000			//W = W % K	    

		ROM2[0] = 33'b000000000100011100010000011000000			//MOV W, Rj	
		ROM2[1] = 33'b000000000100011100010000011000000			//MOV W, PIj  
		ROM2[2] = 33'b001100000100010100010000011100000			//ANR W, Rj   
		ROM2[3] = 33'b010000000100010100010000011100000			//ORR W, Rj   
		ROM2[4] = 33'b011000000100010100010011011100000			//ADR W, Rj   
		ROM2[5] = 33'b010100000100010100010011011100000			//W = W xor Rj    
		ROM2[6] = 33'b011100000100010100010011011100000			//W = W - Rj - CY  
		ROM2[7] = 33'b100000000100010100010011011100000			//W = W * Rj      
		ROM2[8] = 33'b100100000100010100010011011100000			//W = W / Rj      
		ROM2[9] = 33'b101000000100010100010011011100000			//W = W % Rj      
		ROM2[10] = 33'b011000000100010100010011011100000			//W = W + Rj + CY 
		ROM2[11] = 33'b011000000100010100010011011100000			//ADW Ri, Rj      

		ROM3[0] = 33'b000000000100011000000000110000000			//MOV Ri, Rj      
		ROM3[1] = 33'b000000000100011000000000110000000			//MOV POi, Rj     
		ROM3[2] = 33'b000000000100011000000000110000000			//MOV Ri, PIj     
		ROM3[3] = 33'b000000000100011000000000110000000			//MOV POi, PIj    
		ROM3[4] = 33'b000100000100010000000000100100000			//MOV Ri, W       
		ROM3[5] = 33'b000100000100010000000000100100000			//MOV POi, W      
		ROM3[6] = 33'b001100000100010000000011111100000			//Ri = W & Rj     
		ROM3[7] = 33'b010000000100010000000011111100000			//Ri = W or Rj    
		ROM3[8] = 33'b010100000100010000000011111100000			//Ri = W xor Rj   
		ROM3[9] = 33'b011100000100010000000011111100000			//Ri = -Rj - CY   
		ROM3[10] = 33'b100000000100010000000011111100000			//Ri = W * Rj     
		ROM3[11] = 33'b100100000100010000000011111100000			//Ri = W / Rj     
		ROM3[12] = 33'b101000000100010000000011111100000			//Ri = W% Rj 

		ROM4[0] = 33'b000000000100011100011011111100000			//NOP             
		ROM4[1] = 33'b010100000000000100010011111100000			//CPL W           
		ROM4[2] = 33'b101100000100011100011011111100000			//CLR CY          
		ROM4[3] = 33'b110000000100011100011011111100000			//SET CY	    
	end

	always@ (posedge clk) 
        begin
			aux = IR;
			group = IR & 24'hf80000;

			case(group)
			ROM0index: 
			begin
				//MIR = (aux & 24'h000fff);            //get memory/program address
                index = (aux & 24'h0ff000) >> 12;     //get instruction index 
                //MIR <= MIR | ROM0[index]; 
				MIR <= ROM0[index]; 
				indexOut <= index;
				groupOut <= group;
			end
			ROM1index:	//Pareciera estar OK
			begin
                index = (aux & 24'h0f0000) >> 16;     //get instruction index 
                MIR <= ROM1[index]; 
				indexOut <= index;
				groupOut <= group;
			end
			ROM2index:	//OK
			begin
                MIR = (IR & 24'h00001f);            //get register index A bus
                index = (IR & 24'h0fffe0) >> 5;     //get instruction index 
                MIR <= MIR | ROM2[index];  
				indexOut <= index;
				groupOut <= group;
			end
			ROM3index: 		//OK
			begin
                MIR = (IR & 24'h00001f);               //get register index A bus 
                MIR = MIR | ((IR & 24'h0003e0) << 6);  //get register index C bus 
                index = (IR & 24'h0ffc00) >> 10;        //get instruction index 
                MIR <= MIR | ROM3[index];  
				indexOut <= index;
				groupOut <= group;
			end
			ROM4index:
			begin		//Pareciera estar OK
                index = (aux & 24'h07ffff);        //get instruction index 
                MIR <= ROM4[index];  
				indexOut <= index;
				groupOut <= group;
			end
			default:
				MIR <= 33'b000000000111111111111000000011111;	//NOP
		endcase
	    end
endmodule

