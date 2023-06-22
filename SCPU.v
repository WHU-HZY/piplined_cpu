`include "ctrl_encode_def.v"
module SCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    output [31:0] pcW,
    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
    // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    //寄存器选择和寄存器数据
    input  [4:0] reg_sel,    // register selection (for debug use)
    output [31:0] reg_data,  // selected register data (for debug use)
    //字长
    output [2:0] DMType
);


    //输入输出端口（口线）定义
    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation
    wire [2:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero

    //PC相关端口定义
    wire [31:0] NPC;         // next PC

    //Hazard输出相关端口定义
    wire PCWrite;     // control signal to PC write
    wire IF_ID_Write; // control signal to IF/ID write
    wire CTRL_SELECT; // 决定是否对控制信号进行清零

    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    // wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire [31:0] B;           // operator for ALU B
	
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire[31:0] aluout;

    //IF_ID寄存器相关端口定义
    wire [31:0] inst_out;
    wire [31:0] IF_ID_PC

    //CTRL_MUX OUT定义
    //WB
    wire RegWrite_mux;
    wire MemtoReg_mux;
    //MEM
    wire MemWrite_mux;
    wire MemRead_mux;
    wire Branch_mux;
    //EX
    wire ALUSrc_mux;
    wire [4:0]ALUOp_mux;

    //ID_EX寄存器相关端口定义
    wire[63:0] ID_EX_imm,
    wire [31:0] ID_EX_PC,
    wire [31:0] ID_EX_read1_data,
    wire [31:0] ID_EX_read2_data,
    wire [4:0] ID_EX_RS1,
    wire [4:0] ID_EX_RS2,
    wire [4:0] ID_EX_RD,




    //端口赋值
    assign Addr_out=aluout;
	assign B = (ALUSrc) ? immout : RD2;
	assign Data_out = RD2;
	
	assign iimm_shamt=inst_out[24:20];
	assign iimm=inst_out[31:20];
	assign simm={inst_out[31:25],inst_out[11:7]};
	assign bimm={inst_out[31],inst_out[7],inst_out[30:25],inst_out[11:8]};
	assign uimm=inst_out[31:12];
	assign jimm={inst_out[31],inst_out[19:12],inst_out[20],inst_out[30:21]};
   
    assign Op = inst_out[6:0];  // instruction
    assign Funct7 = inst_out[31:25]; // funct7
    assign Funct3 = inst_out[14:12]; // funct3
    assign rs1 = inst_out[19:15];  // rs1
    assign rs2 = inst_out[24:20];  // rs2
    assign rd = inst_out[11:7];  // rd
    assign Imm12 = inst_out[31:20];// 12-bit immediate
    assign IMM = inst_out[31:12];  // 20-bit immediate
   
    //IF_ID寄存器堆
    IF_ID_REF U_IF_ID_REF(
        //input
        .clk(clk),.rst(reset),.inst_in(inst_in),.IF_ID_Write(IF_ID_Write),.PC(PC_out),
        //output
        .inst_out(inst_out)),.PC_ID(IF_ID_PC);


    //ID_EX寄存器堆
    ID_EX_REF U_ID_EX_REF(
        //system input signs
        .clk(clk),
        .rst(reset),

        // ID/EX  signs
        //input 
        .IF_ID_PC(IF_ID_PC),
        .IF_ID_read1_data(RD1),
        .IF_ID_read2_data(RD2),
        .IF_ID_imm(immout),
        .IF_ID_RS1(rs1),
        .IF_ID_RS2(rs2),
        .IF_ID_RD(rd),
        //output
        .ID_EX_imm(ID_EX_imm),
        .ID_EX_PC(ID_EX_PC),
        .ID_EX_read1_data(ID_EX_read1_data),
        .ID_EX_read2_data(ID_EX_read1_data),
        .ID_EX_RS1(ID_EX_RS1),
        .ID_EX_RS2(ID_EX_RS2),
        .ID_EX_RD(ID_EX_RD),

        //WB 
        //input
        input       CTRL_RegWrite, // control signal for register write
        input       CTRL_MemtoReg, // control signal for memory to register
        //output
        output reg  ID_EX_RegWrite,
        output reg  ID_EX_MemtoReg,

        //MEM 
        //input 
        input       CTRL_MEM_MemWrite, // control signal for memory write
        input       CTRL_MEM_MemRead,  // control signal for memory read
        input       CTRL_MEM_Branch,   // control signal for branch
        //output 
        output reg  ID_EX_MemWrite,
        output reg  ID_EX_MemRead,
        output reg  ID_EX_Branch,

        //EX
        //input 
        input  CTRL_ALUSrc,   // ALU source for A
        input [4:0] CTRL_ALUOp,    // ALU opertion
        //ouput 
        output reg  ID_EX_ALUSrc,
        output reg [4:0] ID_EX_ALUOp
    );

    //CTRL_MUX控制单元
    ctrl_mux U_ctrl_mux(
        //input     
        .CTRL_RegWrite(RegWrite),//ok
        .CTRL_MemtoReg(CTRL_MemtoReg),//!!!
        .CTRL_MEM_MemWrite(mem_w),//ok
        .CTRL_MEM_MemRead(CTRL_MEM_MemRead),//!!!
        .CTRL_MEM_Branch(CTRL_MEM_Branch),//!!!
        .CTRL_ALUSrc(ALUSrc),//ok
        .CTRL_ALUOp(ALUOp),.CTRL_SELECT(CTRL_SELECT),//ok
        //ouput
        .ID_EX_RegWrite,(RegWrite_mux).ID_EX_MemtoReg(MemtoReg_mux),
        .ID_EX_MemWrite(MemWrite_mux),.ID_EX_MemRead(MemRead_mux),
        .ID_EX_Branch(Branch_mux),.ID_EX_ALUSrc(ALUSrc_mux),
        .ID_EX_ALUOp(ALUOp_mux)
    );


    //阻塞检测单元
    Hazard_detection_unit U_Hazard_detection_unit(
        //input
       .ID_EX_MemRead(),.IF_ID_RS1(rs1),.IF_ID_RS2(rs2),.IF_ID_RD(rd),
        //output 
       .PCWrite(PCWrite),.IF_ID_Write(IF_ID_Write),.CTRL_SELECT(CTRL_SELECT)
    );


   // 指令控制单元
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
		.RegWrite(RegWrite), .MemWrite(mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel),.DMType(DMType)
	);

    // PC控制单元
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PCWrite(PCWrite), .PC(PC_out) );//从NPC中写入
    
    // PCSrc写入PC的数据来源
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout),.pcW(pcW));

    //立即数扩展控制单元
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

    //寄存器堆控制单元
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite), 
		.A1(rs1), .A2(rs2), .A3(rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);

    //逻辑运算单元
	alu U_alu(.A(RD1), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));

    //寄存器写入数据字长格式选择
    always @*
    begin
	    case(WDSel)
            `WDSel_FromALU: WD<=aluout;
            `WDSel_lw: WD<=Data_in;
            `WDSel_lh: WD<=$signed(Data_in[15:0]);
            `WDSel_lhu: WD<=$unsigned(Data_in[15:0]);
            `WDSel_lb: WD<=$signed(Data_in[7:0]);
            `WDSel_lbu: WD<=$unsigned(Data_in[7:0]);
		    `WDSel_FromPC: WD<=PC_out+4;
	    endcase
    end
endmodule