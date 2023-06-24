module ID_EX_REF(
    // system input signs
    input clk,
    input rst,

    // ID/EX signs
    input [31:0] IF_ID_PC,
    input [31:0] IF_ID_read1_data,
    input [31:0] IF_ID_read2_data,
    input [31:0] IF_ID_imm,
    input [4:0] IF_ID_RS1,
    input [4:0] IF_ID_RS2,
    input [4:0] IF_ID_RD,
    output reg [31:0] ID_EX_imm,
    output reg [31:0] ID_EX_PC,
    output reg [31:0] ID_EX_read1_data,
    output reg [31:0] ID_EX_read2_data,
    output reg [4:0] ID_EX_RS1,
    output reg [4:0] ID_EX_RS2,
    output reg [4:0] ID_EX_RD,

    //WB 
    input       CTRL_RegWrite, // control signal for register write
    input [2:0] CTRL_WDSel,
    output reg  ID_EX_RegWrite,
    output reg [2:0] ID_EX_WDSel,


    //MEM 
    input       CTRL_MEM_MemWrite, // control signal for memory write
    output reg  ID_EX_MemWrite,

    //EX
    input  CTRL_ALUSrc,   // ALU source for A
    input [4:0] CTRL_ALUOp,    // ALU opertion
    input [2:0] CTRL_NPCOp,
    output reg  ID_EX_ALUSrc,
    output reg [4:0] ID_EX_ALUOp,
    output reg [2:0] ID_EX_NPCOp
    );
    

    always @(posedge clk) begin
        if (rst) begin
            //初始化赋值
            ID_EX_PC <= 0;
            ID_EX_read1_data <= 0;
            ID_EX_read2_data <= 0;
            ID_EX_imm <= 0;
            ID_EX_RS1 <= 0;
            ID_EX_RS2 <= 0;
            ID_EX_RD <= 0;
            ID_EX_RegWrite <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_NPCOp <= 0;
            ID_EX_WDSel <= 0;
        end 
        else begin
                ID_EX_PC <= IF_ID_PC;
                ID_EX_read1_data <= IF_ID_read1_data;
                ID_EX_read2_data <= IF_ID_read2_data;
                ID_EX_imm <= IF_ID_imm;
                ID_EX_RS1 <= IF_ID_RS1;
                ID_EX_RS2 <= IF_ID_RS2;
                ID_EX_RD <= IF_ID_RD;
                ID_EX_RegWrite <= CTRL_RegWrite;
                ID_EX_MemWrite <= CTRL_MEM_MemWrite;
                ID_EX_ALUSrc <= CTRL_ALUSrc;
                ID_EX_ALUOp <= CTRL_ALUOp;
                ID_EX_NPCOp <= CTRL_NPCOp;
                ID_EX_WDSel <= CTRL_WDSel;
            end
        end

endmodule
