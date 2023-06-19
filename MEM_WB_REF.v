module EX_MEM_REF(
    // system signs
    input clk,
    input rst,

    // MEM/WB signs
    input [31:0] memread_data,
    input [31:0] EX_MEM_alu_result
  
    output reg [31:0] MEM_WB_memread_data,
    output reg [31:0] MEM_WB_alu_result,

    //WB 
    input       EX_MEM_RegWrite, // control signal for register write
    input       EX_MEM_MemtoReg, // control signal for memory to register
    
    output reg  MEM_WB_RegWrite,
    output reg  MEM_WB_MemtoReg,
    );

    always @(posedge clk) begin
         if(rst)begin
              MEM_WB_memread_data <= 0;
              MEM_WB_alu_result <= 0;
              MEM_WB_RegWrite <= 0;
              MEM_WB_MemtoReg <= 0;
         end
         else begin
              MEM_WB_memread_data <= memread_data;
              MEM_WB_alu_result <= EX_MEM_alu_result;
              MEM_WB_RegWrite <= EX_MEM_RegWrite;
              MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
         end
    end

endmodule
