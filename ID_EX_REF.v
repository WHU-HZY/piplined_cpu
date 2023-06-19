module ID_EX_REF(
    // ID/EX input signs
    input clk,
    input rst,
    input [31:0] IF_ID_PC,
    input [31:0] read1_data,
    input [31:0] read2_data,
    input [63:0] imm,
    input [4:0] IF_ID_RS1,
    input [4:0] IF_ID_RS2,
    input [4:0] IF_ID_RD,

    //WB
    input       RegWrite, // control signal for register write
    input       MemtoReg, // control signal for memory to register

    //MEM
    input       MemWrite, // control signal for memory write
    input       MemRead,  // control signal for memory read
    input       Branch,   // control signal for branch

    //EX
    input       ALUSrc,   // ALU source for A
    input [4:0] ALUOp,    // ALU opertion

    output ID_EX_RS1,
    output ID_
    )

endmodule
