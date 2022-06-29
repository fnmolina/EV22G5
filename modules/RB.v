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

		//Operands  
		output reg [15:0] A, 
		output reg [15:0] B,
		
		//Output memory data		
		output reg [15:0] WRdata);

		
		
	reg [15:0] Register [0:34];
	
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
	always @ (posedge clk) 
		begin 
			if(MC[0])		//memory write 
				WRdata <= Register[WR];
			else if(MC[1])		//memory read
				Register[WR] <= Mdata;
			else
				if(busC <= WR)
					Register[busC] <= dataC;
		end

	//Block 3
	//Esto no me parece del todo bien. Si A o B no cambian podria no guardar un dato actualizado por C en el clk anterior?
	always @ (busA or busB) 
		begin 
			if(busA != (WR+1))
				begin
				B <= Register[busB];
				end
			if(busB != (WR+1))
				begin
					A <= Register[busA];
				end
		end
endmodule