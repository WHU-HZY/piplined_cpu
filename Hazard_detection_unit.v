module Hazard_detection_unit(
    input ID_EX_MemRead,
    input [4:0]IF_ID_RS1,
    input [4:0]IF_ID_RS2,
    input [4:0]ID_EX_RD,
    output PCWrite,
    output IF_ID_Write,
    output CTRL_SELECT);
    //如果上一条指令要写入寄存器到rd中，但是本条指令中使用的RS1和RS2与RD相同，则PCWrite为0，不允许写入PC，进行阻塞
    assign PCWrite = !((ID_EX_MemRead == 1) && ((IF_ID_RS1 == ID_EX_RD) || (IF_ID_RS2 == ID_EX_RD)));
    //如果上一条指令要写入寄存器到rd中，但是本条指令中使用的RS1和RS2与RD相同，则IF_ID_Write为0，不允许写入IF_ID寄存器，进行阻塞
    assign IF_ID_Write = !((ID_EX_MemRead == 1) && ((IF_ID_RS1 == ID_EX_RD) || (IF_ID_RS2 == ID_EX_RD)));
    //如果上一条指令要写入寄存器到rd中，但是本条指令中使用的RS1和RS2与RD相同，则CTRL_SELECT为0，将后续部分控制信号进行清零，进行阻塞
    assign CTRL_SELECT = !(ID_EX_MemRead == 1) && ((IF_ID_RS1 == ID_EX_RD) || (IF_ID_RS2 == ID_EX_RD));

endmodule