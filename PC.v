module PC( clk, rst, NPC, PCWrite, PC);

  input              clk;
  input              rst;

  input       [31:0] NPC;
  input              PCWrite;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;    //PC <= 32'h0000_3000;
    else
    //如果PCWrite为1，则PC才允许写入
      if(PCWrite)
        PC <= NPC;
      
endmodule

