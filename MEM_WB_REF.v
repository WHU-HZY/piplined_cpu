module MEM_WB_REF(
    // system signs
    input clk,
    input rst,
    // EX_MEM signs
    input [31:0]MEM_Read_Data,
    input [31:0]EX_MEM_ALUout,
    input [4:0]EX_MEM_RD,
    output reg [31:0]MEM_WB_Read_Data,
    output reg [31:0]MEM_WB_ALUout,
    output reg [4:0]MEM_WB_RD,
    // WB
    input  EX_MEM_RegWrite,
    input  [2:0] EX_MEM_WDSel,
    output reg MEM_WB_RegWrite,
    output reg [2:0] MEM_WB_WDSel
);
    always @(posedge clk) begin
        if(rst)begin
            MEM_WB_Read_Data <= 0;
            MEM_WB_ALUout <= 0;
            MEM_WB_RD <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_WDSel <= 0;
        end
        else begin
            MEM_WB_Read_Data <= MEM_Read_Data;
            MEM_WB_ALUout <= EX_MEM_ALUout;
            MEM_WB_RD <= EX_MEM_RD;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_WDSel <= EX_MEM_WDSel;
        end
    end

endmodule