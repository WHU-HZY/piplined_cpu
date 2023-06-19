module IF_ID_REF(
    input clk,
    input rst,
    input [31:0] PC,
    input [31:0] inst_in,
    input IF_ID_Write,
    output reg [31:0] PC_ID,
    output reg [31:0] inst_out
    );
    
    always @(posedge clk) begin
        if (rst) begin
            PC_ID <= 0;
            inst_out <= 0;
        end 
        else begin
            if(IF_ID_Write)begin
                PC_ID <= PC;
                inst_out <= inst_in;
            end
        end
    end
endmodule