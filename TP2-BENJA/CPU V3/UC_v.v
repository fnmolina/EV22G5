module UC_v (input clk,
				 input [5:0] C2,
				 input [6:0] T2,
				 input [3:0] ALU1,
				 input [5:0] C1,
				 input [6:0] T1,
				 input [5:0] A0,
				 input [4:0] B0,
				 input [6:0] T0,
				 input MR0, //Memory read.
				 output reg en0,
				 output reg en1);
	reg [2:0] hold;
	reg [2:0] hold_;
//	reg en_;
	initial begin
		hold = 0;
		hold_ = 0;
		en0 <= 1;
		en1 <= 1;
//		en_ = 1;
	end
	always@ (posedge clk) begin
		if (hold > 0 || hold_ > 0) begin
			if(hold_) begin
				hold_ = hold_ >> 1;
				if (hold_ == 0) begin
//					hold = hold >> 1;
//					if (hold == 0)
//						en1 <= 1;
					if(!hold)
						en0 <= 1;
					en1 <= 1;
				end
			end
			else begin
				hold = hold >> 1;
				if (hold == 0)
					en0 <= 1;
			end
		end
		else begin
			case (MR0)
				4'b1100 : begin //MER W,Y
					hold = 3'b100;
					en0 <= 0;
				end
//				default : hold_ = 0;
			endcase				
			if (!hold) begin
				if (T0 & 7'b0000001) begin //read W when W is to be written in 2 clk cycles.
					if (T1 & 7'b0000010) begin
						hold = 2'b10;
						en0 <= 0;
	//					en_ = 0;
					end
				end
				if (T0 & 7'b0000100) begin //read Ri when Ri is to be written in 2 clk cycles.
					if (T1 & 7'b0001000) begin 
						if (A0 == C1 || B0 == C1) begin
							hold = 2'b10;
							en0 <= 0;
	//						en_ = 0;
						end
					end
				end
				if (T0 & 7'b0010000) begin //read CY when CY is to be written in 2 clk cycles.
					if (T1 & 7'b0100000) begin 
						hold = 2'b10;
						en0 <= 0;
	//					en_ = 0;
					end
				end
				case (ALU1)
					4'b1000 : begin //MUL
						hold_ = 3'b100;
						en0 <= 0;
						en1 <= 0;
					end
					4'b1001 : begin //DIV
						hold_ = 3'b100;
						en0 <= 0;
						en1 <= 0;
					end
					4'b1010 : begin //MOD
						hold_ = 3'b100;
						en0 <= 0;
						en1 <= 0;
					end
	//				default : hold_ = 0;
				endcase
				if (!hold && !hold_/* && en_*/) begin
					if (T0 & 7'b0000001) begin //read W when W is to be written in 1 clk cycle.
						if (T2 & 7'b0000010) begin
							//if (en_) begin
								hold = 2'b1;
								en0 <= 0;
							//end
						end
					end
					if (T0 & 7'b0000100) begin //read Ri when Ri is to be written in 1 clk cycle.
						if (T2 & 7'b0001000) begin 
							if (A0 == C2 || B0 == C2) begin
								//if (en_) begin
									hold = 2'b1;
									en0 <= 0;
								//end
							end
						end
					end
					if (T0 & 7'b0010000) begin //read CY when CY is to be written in 1 clk cycle.
						if (T2 & 7'b0100000) begin 
							//if (en_) begin
								hold = 2'b1;
								en0 <= 0;
							//end
						end
					end
				end
	//			if(!hold)
	//				en_ = 1;
			end
		end
	end
endmodule

//module LOGIC_v (input clk,
//					 input [6:0] T, 
//					 output reg en);
//	reg [6:0] T_; //previous T (hold 2 CLK cycle).
//	reg [6:0] T__; //previous T_ (hold 1 CLK cycle).
//	reg [1:0] count;
//	initial begin
//		count = 0;
//		en = 1;
//		T_ = 0;
//		T__ = 0;
//	end
//	always@ (negedge clk) begin
//		if (count > 0) begin
//			count = count - 1;
//			if (count == 0) begin
//				en <= 1;	
//				T_ = T;
//				T__ = 0;
//			end
//			else
//				en <= 0;
//		end
//		else begin
//			if (T & 7'b0000001) begin //read W when W is to be written.
//				if (T_ & 7'b0000010) begin 
//					count = 2'b10;
//					en <= 0;
//				end
//				else
//					en <= 1;
////				else if (T__ & 7'b0000010) begin
////					count = 2'b01;
////					en <= 0;
////				end
//			end
////			else if (T & 7'b0000100) begin //read Ri when Ri is to be written.
////				if (T_ & 7'b0001000) begin 
////					if (A == c || B == C) begin
////						count = 2'b10;
////						en <= 0;
////					end
////				end
////				else if (T__ & 7'b0001000) begin
////					if (A == c || B == C) begin
////						count = 2'b01;
////						en <= 0;
////					end
////				end
////			end
////			else if (T & 7'b0010000) begin //read CY when CY is to be written.
////				if (T_ & 7'b0100000) begin 
////					count = 2'b10;
////					en <= 0;
////				end
////				else if (T__ & 7'b0100000) begin
////					count = 2'b01;
////					en <= 0;
////				end
////			end
//			else 
//				en <= 1;
//			T__ = T_;
//			T_ = T;
//		end
//	end
//endmodule