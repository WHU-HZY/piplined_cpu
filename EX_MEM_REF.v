module EX_MEM_REF(
    // system signs
    input clk,
    input rst,

    // EX/MEM signs
    input [31:0] adder_result,
    input zero,
    input [31:0] alu_result,
    input [31:0] ID_EX_read2_data,//作为写入mem的数据
    input [4:0] ID_EX_RD,

    output reg EX_MEM_adder_result,
    output reg EX_MEM_zero,
    output reg EX_MEM_alu_result,
    output reg [31:0] EX_MEM_read2_data,
    output reg [4:0] EX_MEM_RD,

    //WB 
    input       ID_EX_RegWrite, // control signal for register write
    input       ID_EX_MemtoReg, // control signal for memory to register
    output reg  EX_MEM_RegWrite,
    output reg  EX_MEM_MemtoReg,

    //MEM 
    input       ID_EX_MemWrite, // control signal for memory write
    input       ID_EX_MemRead,  // control signal for memory read
    input       ID_EX_Branch,   // control signal for branch
    output reg  EX_MEM_MemWrite,
    output reg  EX_MEM_MemRead,
    output reg  EX_MEM_Branch

    );

    always @(posedge clk) begin
       if(rst)begin
           EX_MEM_adder_result <= 0;
           EX_MEM_zero <= 0;
           EX_MEM_alu_result <= 0;
           EX_MEM_read2_data <= 0;
           EX_MEM_RD <= 0;
           EX_MEM_RegWrite <= 0;
           EX_MEM_MemtoReg <= 0;
           EX_MEM_MemWrite <= 0;
           EX_MEM_MemRead <= 0;
           EX_MEM_Branch <= 0;
       end
       else begin
           EX_MEM_adder_result <= adder_result;
           EX_MEM_zero <= zero;
           EX_MEM_alu_result <= alu_result;
           EX_MEM_read2_data <= ID_EX_read2_data;
           EX_MEM_RD <= ID_EX_RD;
           EX_MEM_RegWrite <= ID_EX_RegWrite;
           EX_MEM_MemtoReg <= ID_EX_MemtoReg;
           EX_MEM_MemWrite <= ID_EX_MemWrite;
           EX_MEM_MemRead <= ID_EX_MemRead;
           EX_MEM_Branch <= ID_EX_Branch;
       end
    end

endmodule
