`include "ctrl_encode_def.v"

module NPC(
   //input
   input Zero,
   input [31:0] PC,
   input [2:0] NPCOp, 
   input [31:0] PCPLUS4, 
   input [31:0] PCPLUSimm, 
   input [31:0] aluout,
   //output 
   output reg [31:0] NPC, 
   output [31:0] pcW
);  // next pc module
    
   assign pcW = PC;
    //这里解决了之前zero不能时间倒流传送到if阶段的问题
   always @(*) begin
      case (NPCOp&{2'b11,Zero})
         `NPC_PLUS4:  NPC = PCPLUS4;
         `NPC_BRANCH: NPC = PCPLUSimm;
         `NPC_JUMP:   NPC = PCPLUSimm;
		   `NPC_JALR:	 NPC = aluout;
          default:    NPC = PCPLUS4;
      endcase
   end // end always
   
endmodule
