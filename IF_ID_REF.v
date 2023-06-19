module IF_ID_REF(
    input clk,
    input rst,
    input [31:0] PC,
    input [31:0] inst,
    input IF_ID_Write,
    output reg [31:0] PC_ID,
    output reg [31:0] inst_ID
    );
    
    always @(posedge clk) begin
        if (rst) begin
            PC_ID <= 0;
            inst_ID <= 0;
        end 
        else begin
            PC_ID <= PC;
            inst_ID <= inst;
        end
    end
endmodule