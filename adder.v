module ADDER(
    input [31:0] PC_Now,
    input [31:0] ID_EX_PC,
    input [31:0] IMM,
    output [31:0] PCPLUSimm,
    output [31:0] PCPLUS4
);
    assign PCPLUSimm = ID_EX_PC + IMM;
    assign PCPLUS4 = PC_Now + 4;
endmodule