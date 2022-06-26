module RB 
	(	input wire clk, 
		//Señales de control de microinstruccion 
		input wire [1:0] MC,	//bit0 MW, bit1 MR
		input wire [5:0] WRC, 
		input wire [4:0] busA, 
		input wire [5:0] busB, 

		//Input data Bus C
		input wire [15:0] busC,
		
		//Input data memory
		input wire [15:0] Mdata,

		//Operands  
		output reg [15:0] A, 
		output reg [15:0] B
		
		//Output memory data		
		output reg [15:0] WRdata);

	/* 	
	*	35 16bit registers:
	*	0-27:	General Purpose Registers 
	*	28-29:	Input Ports	
	*	30-31:	Output Ports
	*	32-33: 	Aux registers 
	*	34:		Working register
	*/
	reg [15:0] Register [0:34];

	//working register index 
	parameter WR = 34;

	//Block 2
	always @ (posedge clk) 
		begin 
			if(MC[0])
				WRdata <= Register[WR];
			else if(MC[0])
				Register[WR] <= Mdata;
			else
				Register[WRC] <= busC;
		end

	//Block 3
	//Esto no me parece del todo bien. Si A o B no cambian podria no guardar un dato actualizado por C en el clk anterior?
	always @ (busA or busB) 
		begin 
			A <= R[busA];
			B <= R[busB];
		end
endmodule