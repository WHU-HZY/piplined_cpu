module EX_MEM_REF(
    // system signs
    input clk,
    input rst,

    // EX/MEM signs
    input [31:0] EX_NPC,
    input [31:0] alu_result,
    input [31:0] ID_EX_read2_data,//作为写入mem的数据
    input [4:0] ID_EX_RD,

    output reg [31:0]EX_MEM_NPC,
    output reg [31:0]EX_MEM_alu_result,
    output reg [31:0] EX_MEM_read2_data,
    output reg [4:0] EX_MEM_RD,

    //WB 
    input       ID_EX_RegWrite, // control signal for register write
    input  [2:0]     ID_EX_WDSel,
    output reg  EX_MEM_RegWrite,
    output reg [2:0] EX_MEM_WDSel,
    //MEM 
    input  [2:0] ID_EX_DMType,
    input       ID_EX_MemRead,  // control signal for memory read
    input       ID_EX_MemWrite, // control signal for memory write
    output reg [2:0] EX_MEM_DMType,
    output reg  EX_MEM_MemRead,
    output reg  EX_MEM_MemWrite
    );

    always @(posedge clk) begin
       if(rst)begin
           EX_MEM_NPC <= 0;
           EX_MEM_alu_result <= 0;
           EX_MEM_read2_data <= 0;
           EX_MEM_RD <= 0;
           EX_MEM_RegWrite <= 0;
           EX_MEM_MemWrite <= 0;
           EX_MEM_MemRead <= 0;
       end
       else begin
           EX_MEM_NPC <= EX_NPC;
           EX_MEM_alu_result <= alu_result;
           EX_MEM_read2_data <= ID_EX_read2_data;
           EX_MEM_RD <= ID_EX_RD;
           EX_MEM_RegWrite <= ID_EX_RegWrite;
           EX_MEM_MemWrite <= ID_EX_MemWrite;
           EX_MEM_MemRead <= ID_EX_MemRead;
       end
    end

endmodule
