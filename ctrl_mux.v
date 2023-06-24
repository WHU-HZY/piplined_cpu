module ctrl_mux(
    //控制信号
    input CTRL_SELECT,
    //WB 
    input  [2:0]CTRL_WDSel,
    input       CTRL_RegWrite, // control signal for register write
    output reg  ID_EX_RegWrite,
    output reg [2:0] ID_EX_WDSel,

    //MEM 
    input       CTRL_MEM_MemWrite, // control signal for memory write
    output reg  ID_EX_MemWrite,

    //EX
    input  CTRL_ALUSrc,   // ALU source for A
    input [4:0] CTRL_ALUOp,    // ALU opertion
    input [2:0]  NPCOp,
    output reg  ID_EX_ALUSrc,
    output reg [4:0] ID_EX_ALUOp,
    output reg [2:0] ID_EX_NPCOp
    );
    
    always @(*) begin
        if(CTRL_SELECT)begin //如果控制信号选择不进行清零
            ID_EX_RegWrite = CTRL_RegWrite;
            ID_EX_MemWrite = CTRL_MEM_MemWrite;
            ID_EX_ALUSrc <= CTRL_ALUSrc;
            ID_EX_ALUOp <= CTRL_ALUOp;
            ID_EX_NPCOp <= NPCOp;
        end
        else begin //如果控制信号选择进行清零
            ID_EX_RegWrite <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_NPCOp <= 0;
        end
    end 
endmodule