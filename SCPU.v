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
    // input  [4:0] reg_sel,    // register selection (for debug use)
    // output [31:0] reg_data,  // selected register data (for debug use)
    //字长
    output [2:0] DMType
);
  

    //ctrl输入输出端口（口线）定义
    wire        MemRead;     //control signal to memory
    wire        MemWrite;
    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation
    wire [2:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero

    //PC相关端口定义
    wire [31:0] EX_NPC;         // next PC

    //Hazard输出相关端口定义
    wire PCWrite;     // control signal to PC write
    wire IF_ID_Write; // control signal to IF/ID write
    wire CTRL_SELECT; // 决定是否对控制信号进行清零

    //指令decode相关端口定义
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
    wire [2:0]  ID_DMType;      //字长类型
	
    //立即数扩展相关端口定义
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire[31:0] aluout;

    //IF_ID寄存器相关端口定义
    wire [31:0] inst_out;
    wire [31:0] IF_ID_PC;

    //CTRL_MUX OUT定义
    //WB
    wire RegWrite_mux;
    //MEM
    wire MemRead_mux;
    wire MemWrite_mux;
    wire [2:0] DMType_mux;
    //EX
    wire ALUSrc_mux;
    wire [4:0]ALUOp_mux;
    wire [2:0]NPCOp_mux;


    //ID_EX寄存器相关端口定义
    //output
    wire[31:0] ID_EX_imm;
    wire [31:0] ID_EX_PC;
    wire [31:0] ID_EX_read1_data;
    wire [31:0] ID_EX_read2_data;
    wire [4:0] ID_EX_RS1;
    wire [4:0] ID_EX_RS2;
    wire [4:0] ID_EX_RD;
    //WB output
    wire ID_EX_RegWrite;
    wire [2:0] ID_EX_WDSel;
    //MEM output
    wire ID_EX_MemWrite;
    wire ID_EX_MemRead;
    wire [2:0] ID_EX_DMType;
    //EX output
    wire ID_EX_ALUSrc;
    wire [4:0]ID_EX_ALUOp;
    wire [2:0]ID_EX_NPCOp;


    //EX_MEM寄存器堆
    wire [31:0]EX_MEM_NPC;
    wire [31:0]EX_MEM_ALUout;
    wire [31:0]EX_MEM_read2_data;
    wire [4:0]EX_MEM_RD;
    wire EX_MEM_RegWrite;
    wire [2:0]EX_MEM_WDSel;
    wire EX_MEM_MemRead;
    //MEM_WB寄存器堆
    wire [31:0]MEM_WB_Data_in;
    wire [31:0]MEM_WB_ALUout;
    wire [4:0]MEM_WB_RD;
    wire MEM_WB_RegWrite;
    wire [2:0]MEM_WB_WDSel;


    //adder模块相关端口定义
    wire [31:0] adder_PCPLUSimm;
    wire [31:0] adder_PCPLUS4;


    //ALU赋值定义
    assign Addr_out=aluout;
	assign B = (ID_EX_ALUSrc) ? ID_EX_imm : ID_EX_read2_data;
	assign Data_out = EX_MEM_read2_data;
   //立即数赋值定义
	assign iimm_shamt=inst_out[24:20];
	assign iimm=inst_out[31:20];
	assign simm={inst_out[31:25],inst_out[11:7]};
	assign bimm={inst_out[31],inst_out[7],inst_out[30:25],inst_out[11:8]};
	assign uimm=inst_out[31:12];
	assign jimm={inst_out[31],inst_out[19:12],inst_out[20],inst_out[30:21]};
   //指令decode端口赋值定义
    assign Op = inst_out[6:0];  // instruction
    assign Funct7 = inst_out[31:25]; // funct7
    assign Funct3 = inst_out[14:12]; // funct3
    assign rs1 = inst_out[19:15];  // rs1
    assign rs2 = inst_out[24:20];  // rs2
    assign rd = inst_out[11:7];  // rd
    assign Imm12 = inst_out[31:20];// 12-bit immediate
    assign IMM = inst_out[31:12];  // 20-bit immediate
   //data memory输出控制信号定义
    assign mem_w = EX_MEM_MemWrite;

    //IF_ID寄存器堆
    IF_ID_REF U_IF_ID_REF(
        //input
        .clk(clk),.rst(reset),.inst_in(inst_in),.IF_ID_Write(IF_ID_Write),.PC(PC_out),
        //output
        .inst_out(inst_out),.PC_ID(IF_ID_PC));


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
        .ID_EX_read2_data(ID_EX_read2_data),
        .ID_EX_RS1(ID_EX_RS1),
        .ID_EX_RS2(ID_EX_RS2),
        .ID_EX_RD(ID_EX_RD),
        //WB 
        //input
        .CTRL_WDSel(WDSel_mux),//ok
        .CTRL_RegWrite(RegWrite_mux), // control signal for register write
        //output
        .ID_EX_WDSel(ID_EX_WDSel),
        .ID_EX_RegWrite(ID_EX_RegWrite),
        //MEM 
        //input 
        .CTRL_MEM_MemRead(MemRead_mux), // control signal for memory read
        .CTRL_MEM_MemWrite(MemWrite_mux), // control signal for memory write
        .CTRL_DMType(DMType_mux),
        //output 
        .ID_EX_MemWrite(ID_EX_MemWrite),
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_DMType(ID_EX_DMType),
        //EX
        //input 
        .CTRL_ALUSrc(ALUSrc_mux),   // ALU source for A
        .CTRL_ALUOp(ALUOp_mux),    // ALU opertion
        .CTRL_NPCOp(NPCOp_mux),
        //ouput 
        .ID_EX_ALUSrc(ID_EX_ALUSrc),
        .ID_EX_ALUOp(ID_EX_ALUOp),
        .ID_EX_NPCOp(ID_EX_NPCOp)
    );



    EX_MEM_REF U_EX_MEM_REF(
        // system input signs
        .clk(clk),
        .rst(reset),
        // EX/MEM  signs
        //input 
        .EX_NPC(EX_NPC),//下一条指令的地址
        .alu_result(aluout),
        .ID_EX_read2_data(ID_EX_read2_data),//作为写入mem的数据
        .ID_EX_RD(ID_EX_RD),
        //output 
        .EX_MEM_NPC(EX_MEM_NPC),
        .EX_MEM_alu_result(EX_MEM_ALUout),
        .EX_MEM_read2_data(EX_MEM_read2_data),
        .EX_MEM_RD(EX_MEM_RD),

        //WB 
        //input 
        .ID_EX_WDSel(ID_EX_WDSel),
        .ID_EX_RegWrite(ID_EX_RegWrite), // control signal for register write
        
        //output
        .EX_MEM_WDSel(EX_MEM_WDSel),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),

        //MEM 
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_MemWrite(ID_EX_MemWrite), // control signal for memory write
        .ID_EX_DMType(ID_EX_DMType),
        //output
        .EX_MEM_MemRead(EX_MEM_MemRead),
        .EX_MEM_MemWrite(EX_MEM_MemWrite),
        .EX_MEM_DMType(DMType)
    );


    //MEM_WB寄存器堆
    MEM_WB_REF U_MEM_WB_REF(
        // system input signs
        .clk(clk),
        .rst(reset),
        // MEM/WB  signs
        //input 
        .MEM_Read_Data(Data_in),
        .EX_MEM_ALUout(EX_MEM_ALUout),
        .EX_MEM_RD(EX_MEM_RD),
        //output 
        .MEM_WB_Data_in(MEM_WB_Data_in),
        .MEM_WB_ALUout(MEM_WB_ALUout),
        .MEM_WB_RD(MEM_WB_RD),

        //WB 
        //input 
        .EX_MEM_RegWrite(EX_MEM_RegWrite), // control signal for register write
        .EX_MEM_WDSel(EX_MEM_WDSel),
        //output
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_WDSel(MEM_WB_WDSel)
    );


    //CTRL_MUX控制单元
    ctrl_mux U_ctrl_mux(
        .CTRL_SELECT(CTRL_SELECT),//ok
        //input     
        .CTRL_RegWrite(RegWrite),//ok
        .CTRL_MemWrite(MemWrite),//ok
        .CTRL_ALUSrc(ALUSrc),//ok
        .CTRL_ALUOp(ALUOp),
        .CTRL_WDSel(WDSel),
        .CTRL_NPCOp(NPCOp),
        .CTRL_MemRead(MemRead),
        .CTRL_DMType(ID_DMType),
        //ouput
        .ID_EX_RegWrite(RegWrite_mux),
        .ID_EX_MemWrite(MemWrite_mux),
        .ID_EX_ALUSrc(ALUSrc_mux),
        .ID_EX_ALUOp(ALUOp_mux),
        .ID_EX_NPCOp(NPCOp_mux),
        .ID_EX_WDSel(WDSel_mux),
        .ID_EX_MemRead(MemRead_mux),
        .ID_EX_DMType(DMType_mux)
    );


    //阻塞检测单元
    Hazard_detection_unit U_Hazard_detection_unit(
        //input
       .ID_EX_MemRead(ID_EX_MemRead),.IF_ID_RS1(rs1),.IF_ID_RS2(rs2),.ID_EX_RD(ID_EX_RD),
        //output 
       .PCWrite(PCWrite),.IF_ID_Write(IF_ID_Write),.CTRL_SELECT(CTRL_SELECT)
    );


   // 指令控制单元
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3),  
		.RegWrite(RegWrite), .MemWrite(MemWrite),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel),.DMType(ID_DMType),
        .MemRead(MemRead)
	);

    //这里NPC记得替换成EX_MEM阶段的
    // PC控制单元
	PC U_PC(.clk(clk), .rst(reset), .NPC(EX_MEM_NPC), .PCWrite(PCWrite),.PC(PC_out));//从NPC中写入
    

    // PCSrc写入PC的数据来源
	NPC U_NPC(
        //input 
        .Zero(Zero),
        .PC(PC_out), 
        .NPCOp(ID_EX_NPCOp), 
        .PCPLUS4(adder_PCPLUS4),
        .PCPLUSimm(adder_PCPLUSimm),
        .aluout(aluout),
        //output
        .NPC(EX_NPC), 
        .pcW(pcW)
    );


    ADDER U_ADDER(
        //input 
        .PC_Now(PC_out),
        .ID_EX_PC(ID_EX_PC),
        .IMM(ID_EX_imm),
        //output
        .PCPLUSimm(adder_PCPLUSimm),
        .PCPLUS4(adder_PCPLUS4)
    );
    

    //立即数扩展控制单元
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

    //寄存器堆控制单元
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(MEM_WB_RegWrite), 
		.A1(rs1), .A2(rs2), .A3(rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);

    //逻辑运算单元
	alu U_alu(.A(ID_EX_read1_data), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(IF_ID_PC));

    //寄存器写入数据字长格式选择
    always @*
    begin
	    case(WDSel)
            `WDSel_FromALU: WD<=aluout;
            `WDSel_lw: WD<=MEM_WB_Data_in;
            `WDSel_lh: WD<=$signed(MEM_WB_Data_in[15:0]);
            `WDSel_lhu: WD<=$unsigned(MEM_WB_Data_in[15:0]);
            `WDSel_lb: WD<=$signed(MEM_WB_Data_in[7:0]);
            `WDSel_lbu: WD<=$unsigned(MEM_WB_Data_in[7:0]);
		    `WDSel_FromPC: WD<=ID_EX_PC+4;
	    endcase
    end
endmodule 