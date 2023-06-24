`include "ctrl_encode_def.v"

module NPC(
   //input
   input [31:0] PC,
   input [2:0] NPCOp, 
   input [31:0] PCPLUS4, 
   input [31:0] PCPLUSimm, 
   output [31:0] aluout,
   //output 
   output reg [31:0] NPC, 
   output [31:0] pcW
);  // next pc module
    
   assign pcW = PC;
   always @(*) begin
      case (NPCOp)
         `NPC_PLUS4:  NPC = PCPLUS4;
         `NPC_BRANCH: NPC = PCPLUSimm;
         `NPC_JUMP:   NPC = PCPLUSimm;
		   `NPC_JALR:	 NPC = aluout;
          default:    NPC = PCPLUS4;
      endcase
   end // end always
   
endmodule
