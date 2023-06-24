module ADDER(
    input [31:0] PC,
    input [31:0] IMM,
    output [31:0] PCPLUSimm,
    output [31:0] PCPLUS4
);
    assign PCPLUSimm = PC + IMM;
    assign PCPLUS4 = PC + 4;
endmodule