module FSM(
	input clk_25MHz,
	input [15:0] H_counter,
	input [15:0] V_counter,
	output reg Hsync,
	output reg Vsync,
	output reg Red,
	output reg Green,
	output reg Blue
);

reg[24:0] cnt;
reg[3:0] state;
reg[3:0] color;

initial begin
	Hsync = 1'b0;
	Vsync = 1'b0;
	Red = 1'b0;
	Green = 1'b0;
	Blue = 1'b0;
	cnt = 0;
	state = 0;
	color = 3'b000;
	//testLed = 1;
end

always@ (posedge clk_25MHz) begin
	
	if (cnt < 25000000)
		cnt <= cnt + 1;
		
	else begin
		cnt <= 0;
		
		case (state)
			0 : color <= 3'b111;
			1 : color <= 3'b001;
			2 : color <= 3'b011;
			3 : color <= 3'b010;
			4 : color <= 3'b110;
			5 : color <= 3'b100;
			6 : color <= 3'b101;
			7 : color <= 3'b000;
		endcase
		
		state <= (state + 1) % 8;
		//testLed <= (state % 2);
	end
	
	//Assign outputs
	Hsync <= (H_counter < 96) ? 1'b1 : 1'b0;
	Vsync <= (V_counter < 2) ? 1'b1 : 1'b0;
	
	if (H_counter > 143 && H_counter < 784 && V_counter > 34 && V_counter < 515) begin
		Red <= color[0];
		Green <= color[1];
		Blue <= color[2];
	end
	else begin
		Red <= 1'b0;
		Green <= 1'b0;
		Blue <= 1'b0;		
	end
	
end

endmodule 