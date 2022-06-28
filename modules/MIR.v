module MIR 
    (   input wire  clk,
        input [23:0] IR, //Instruction
		output reg [23:0] indexOut,
		output reg [23:0] groupOut,
        output reg [32:0] MIR); //Microinstruction 


    reg [32:0] ROM0 [0:7];   
    reg [32:0] ROM1 [0:7];
    reg [32:0] ROM2 [0:11];
    reg [32:0] ROM3 [0:10];
    reg [32:0] ROM4 [0:6];

    reg [23:0] aux;
    reg [23:0] group;
    reg [23:0] index;

    parameter ROM0index = 24'h800000;
    parameter ROM1index = 24'h400000;
    parameter ROM2index = 24'h200000;
    parameter ROM3index = 24'h100000;
    parameter ROM4index = 24'h080000;

	initial begin       

		ROM0[0] = 33'b000000000000000100011100000000000; //JMP X
		ROM0[1] = 33'b000000000000000100011100000100000; //JZE X
		ROM0[2] = 33'b000000000000000100011100000100000; //JNE X
		ROM0[3] = 33'b000000000000000100011101000000000; //JCY X
		ROM0[4] = 33'b000000000000000100011100000000000; //RET 
		ROM0[5] = 33'b000000000000000100011100000000000; //BSR S
		ROM0[6] = 33'b000000000000001100011000000100000; //MOM Y, W
      	ROM0[7] = 33'b000000000000010100011000001000000; //MOM W, Y
		
		ROM1[0] = 33'b100010000001001010001000100000011; //MOK W,K
		ROM1[1] = 33'b100010000001001010001000100000011; //MOK W,K
		ROM1[2] = 33'b100010000001000011001000100000011; //ANK W,K
		ROM1[3] = 33'b100010000001000100001000100000011; //ORK W,K
		ROM1[4] = 33'b100010000001000110001000100110011; //ADK W,K
		ROM1[5] = 33'b100010000001000101001000100000011; //XOK W,K
		ROM1[6] = 33'b100010000001000111001000100110011; //SUK W,K
		ROM1[7] = 33'b100010000001001000001000100000011; //MUK W,K

		//ROM2[7] = 33'b100010000001001001001000100000011; //DIK W,K
        //ROM2[0] = 33'b000000000001000001001000100000010; //EQK W,K
		
		ROM2[0] = 33'b000000000000000100010000011000000; //EQR Ri,Rj //EQR POi,Rj //EQR Ri,PIj //EQR POi,PIj		OK  
		ROM2[1] = 33'b100010000000000000000000000001001; //EQR Ri,W //EQR POi,W
		ROM2[2] = 33'b100010000000000011000000000001101; //ANR Ri,Rj
		ROM2[3] = 33'b100010000000000100000000000001101; //ORR Ri,Rj
		ROM2[4] = 33'b100010000000000101000000000001101; //XOR Ri,Rj
		ROM2[5] = 33'b100010000000000110000000000111101; //ADR Ri,Rj
		ROM2[6] = 33'b100010000000000111000000000111101; //SUR Ri,Rj
		ROM2[7] = 33'b100010000000001000000000000001101; //MUR Ri,Rj
		ROM2[8] = 33'b100010000000001001000000000001101; //DIR Ri,Rj
		ROM2[9] = 33'b100010000000001010000000000001101; //MOR Ri,Rj
		ROM2[10] = 33'b100010000000000000010000000001001; //SLR Ri,W
		ROM2[11] = 33'b100010000000000000100000000001001; //SRR Ri,W

		ROM3[0] = 33'b000000000000000001001000100000110; //EQW W,Rj //EQW W,PIj
		ROM3[1] = 33'b000100000000000000000000000000000; //ANW W,Rj
		ROM3[2] = 33'b100010000000000100001000100000111; //ORW W,Rj
		ROM3[3] = 33'b100010000000000101001000100000111; //XOW W,Rj
		ROM3[4] = 33'b100010000000000110001000100110111; //ADW W,Rj
		ROM3[5] = 33'b000100000100010000000000100100000; //MOV Ri,W		//OK
		ROM3[6] = 33'b100010000000001000001000100000111; //MUW W,Rj
		ROM3[7] = 33'b100010000000001001001000100000111; //DIW W,Rj
		ROM3[8] = 33'b100010000000001010001000100000111; //MOW W,Rj
		ROM3[9] = 33'b000000000000000001011000100000110; //SLW W,Rj
		ROM3[10] = 33'b000000000000000001101000100000110; //SRW W,Rj

		ROM4[0] = 33'b100010000000000010001000100000011; //NOT W
		ROM4[1] = 33'b100010000000000000011000100000011; //SHL W
		ROM4[2] = 33'b100010000000000000101000100000011; //SHR W
		ROM4[3] = 33'b000000000000001011001000110100000; //CLR CY
		ROM4[4] = 33'b000000000000001100001000110100000; //SET CY
		ROM4[5] = 33'b000000000000000000001000110000000; //RET
		ROM4[6] = 33'b000000000000000000001000110000000; //NOP
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
			ROM1index:
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
			begin
                index = (aux & 24'h07ffff);        //get instruction index 
                MIR <= MIR | ROM4[index];  
				indexOut <= index;
				groupOut <= group;
			end
			default:
				MIR <= 33'b000000000111111111111000000011111;	//NOP
		endcase
	    end
endmodule

