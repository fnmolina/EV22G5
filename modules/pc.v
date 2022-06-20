module pc (
    input enable,
    input clk,
    input [15:0] IR,
    input [3:0] CCR,
    output reg [11:0] pc_output
);

    reg [11:0] pc_aux;
    reg [15:0] temp;
    reg start;
    reg hold;
    initial begin
        pc_output   =   0;
        pc_aux      =   0;
        start       =   0;
        hold        =   0;
    end
    
    always @(posedge clk) begin
        
    end
endmodule