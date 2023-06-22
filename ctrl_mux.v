module ctrl_mux(
    //控制信号
    input CTRL_SELECT,
    //WB 
    input       CTRL_RegWrite, // control signal for register write
    input       CTRL_MemtoReg, // control signal for memory to register
    output      ID_EX_RegWrite,
    output      ID_EX_MemtoReg,

    //MEM 
    input       CTRL_MEM_MemWrite, // control signal for memory write
    input       CTRL_MEM_MemRead,  // control signal for memory read
    input       CTRL_MEM_Branch,   // control signal for branch
    output      ID_EX_MemWrite,
    output      ID_EX_MemRead,
    output      ID_EX_Branch,

    //EX
    input  CTRL_ALUSrc,   // ALU source for A
    input [4:0] CTRL_ALUOp,    // ALU opertion
    output      ID_EX_ALUSrc,
    output[4:0] ID_EX_ALUOp
    );
    
    if(CTRL_SELECT)begin //如果控制信号选择不进行清零
        ID_EX_RegWrite <= CTRL_RegWrite;
        ID_EX_MemtoReg <= CTRL_MemtoReg;
        ID_EX_MemWrite <= CTRL_MEM_MemWrite;
        ID_EX_MemRead <= CTRL_MEM_MemRead;
        ID_EX_Branch <= CTRL_MEM_Branch;
        ID_EX_ALUSrc <= CTRL_ALUSrc;
        ID_EX_ALUOp <= CTRL_ALUOp;
    end
    else begin //如果控制信号选择进行清零
        ID_EX_RegWrite <= 0;
        ID_EX_MemtoReg <= 0;
        ID_EX_MemWrite <= 0;
        ID_EX_MemRead <= 0;
        ID_EX_Branch <= 0;
        ID_EX_ALUSrc <= 0;
        ID_EX_ALUOp <= 0;

    end
endmodule