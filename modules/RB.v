module RB	 
	(	input wire clk, 
		//Señales de control de microinstruccion 
		input wire [1:0] MC,	//bit0 MW, bit1 MR
		input wire [5:0] busC, 
		input wire [4:0] busA, 
		input wire [5:0] busB, 

		//Input data Bus C
		input wire [15:0] dataC,
		
		//Input data memory
		input wire [15:0] Mdata,
		
		input wire [15:0] PI0,
		input wire [15:0] PI1,
		
		input wire regWrite,
		input wire regRead,
		
		input wire workRegWrite,
		input wire workRegRead,
	
		//Operands  
		output reg [15:0] A, 
		output reg [15:0] B,
		
		//Output memory data		
		output reg [15:0] WRdata,
		output reg [15:0] WRcurrent,
		output reg [15:0] AUXreg,
		output reg [15:0] PO0,
		output reg [15:0] PO1
		);

		
		
	reg [15:0] Register [0:35];
	
	//working register index 
	parameter WR = 34;
	
	initial
		begin
			Register[1] = 16'b0000000011110000;
			Register[2] = 16'b11110000;
			Register[3] = 16'b11110000;
			Register[WR] = 16'b0000000000001111;
			
		end 



	//Block 2
	always @ (regWrite or workRegWrite) 
		begin 
			if(busC!= 6'b100011) begin
//			if(MC[0])		//memory write 
//				WRdata <= Register[WR];
//			else if(MC[1])		//memory read
//				Register[WR] <= Mdata;
//			else
//			if (regWrite or workRegWrite) begin					
			Register[busC] <= dataC;
//			end
			end
			
			WRcurrent <= Register[WR];
			AUXreg <= Register[35];
			PO0 <= Register[30];
			PO1 <= Register[31];
			
		end

	//Block 3
	//Esto no me parece del todo bien. Si A o B no cambian podria no guardar un dato actualizado por C en el clk anterior?
	always @ (busA or busB) 
		begin 
			if (regRead || workRegRead) begin					

				B <= Register[busB];
	
				A <= Register[busA];
			end	
			
		end
endmodule