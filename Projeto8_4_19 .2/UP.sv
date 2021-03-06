module UP

    	(input logic clk,
	 input logic rst,
	 input logic MemRead, 
	 output logic SelMux2,
	 output logic [1:0]SelMux4,
	 output logic SelMuxMem,
     	 output logic PCwrite,
	 output logic IRwrite,
	 output logic RegWrite,
	 output logic dataout1,
	 output logic dataout2,
	 output logic loadRegA,
	 output logic loadRegB,
	 output logic loadRegAluOut,
	 output logic MemData_Read,	
	 output logic loadRegMemData,
	 output logic [63:0] PCExit,
	 output logic [63:0] AluExit,
 	 output logic [63:0] RegA_Exit,
 	 output logic [63:0] RegB_Exit,
 	 output logic [63:0] AluOut_Exit,
	 output logic [63:0] ReadData_Exit,
	 output logic [63:0] MemDataReg_Exit,
	 output logic [4:0] i19_15,
	 output logic [4:0] i24_20,
	 output logic [4:0] i11_7,
	 output logic [6:0] i6_0,
	 output logic [31:0] i31_0,
	 output logic [63:0] SignExit,
	 output logic [63:0] ShiftExit,
	 output logic [31:0] MemExit,
	 output logic [63:0] MuxA_Exit,
	 output logic [63:0] MuxB_Exit,
	 output logic [63:0] MuxMem_Exit,
	 output logic exitState,
	 output logic [2:0] AluOperation);

parameter PCincrement = 64'd4; 
	
	Controle UnitCtrl

       		(.clk(clk),
		.rst(rst),
		.PCwrite(PCwrite),
		.MemRead(MemRead),
		.SelMux2(SelMux2),
	        .SelMux4(SelMux4),
		.AluOperation(AluOperation),
		.IRwrite(IRwrite),
		.RegWrite(RegWrite),
		.loadRegA(loadRegA),
		.loadRegB(loadRegB),
		.exitState(exitState));
		//. (loadRegAluOut)
		//. (ReadData_Read);

	Memoria32 MemoryInstruction

       		(.raddress(PCExit[31:0]),
		.Clk(clk),
		.Dataout(MemExit),
		.Wr(MemRead));

	
	register PC

	        (.clk(clk),
		.reset(rst),
		.regWrite(PCwrite),
		.DadoIn(AluExit),
		.DadoOut(PCExit));

	Instr_Reg_RISC_V RegInstruction

	  	(.Clk(clk),
		.Reset(rst),
		.Load_ir(IRwrite),
		.Entrada(MemExit),
		.Instr19_15(i19_15),
		.Instr24_20(i24_20),
		.Instr11_7(i11_7),
		.Instr6_0(i6_0),
		.Instr31_0(i31_0));

	
	SingExtend sinalExt

		(.entrada(i31_0),
		.saida(SignExit));

	Deslocamento Shift

		(.In(SignExit),
		 .Out(ShiftExit));			


	bancoReg Banco_Reg 

		(.clk(clk),
		.regreader1(i19_15),
		.regreader2(i24_20),
		.regwriteadress(i11_7),
		.datain(MuxMem_Exit), //escrever no registrador: mem->reg (store)
		.dataout1(dataout1),
		.dataout2(dataout2),
		.rst(rst),
		.RegWrite(RegWrite));

	register A

	        (.clk(clk),
		.reset(rst),
		.regWrite(loadRegA),
		.DadoIn(dataout1),
		.DadoOut(RegA_Exit));


	register B

	        (.clk(clk),
		.reset(rst),
		.regWrite(loadRegB), 
		.DadoIn(dataout2),
		.DadoOut(RegB_Exit));

	mux_2in MuxA

		(.SelMux2(SelMux2),
		.MuxA_a(PCExit),
		.MuxA_b(RegA_Exit),
		.f_2in(MuxA_Exit));

	mux_4in MuxB

		(.SelMux4(SelMux4),
		.MuxB_a(RegB_Exit),
		.MuxB_b(PCincrement),
		.MuxB_c(SignExit),
		.MuxB_d(ShiftExit));

	mux_2in muxPc

		(
		);	

	ula64 Ula

       	        (.A(MuxA_Exit),
		.B(MuxB_Exit),
		.Seletor(AluOperation),
		.S(AluExit));
	
	register AluOut
	
	 	(.clk(clk),
		.reset(rst),
		.regWrite(loadRegAluOut), 
		.DadoIn(AluExit),
		.DadoOut(AluOut_Exit));

	Memoria64 MemoryData

		(.raddress (AluOut_Exit),
		 .Clk(clk),
		.Datain(RegB_Exit),
		.Dataout(ReadData_Exit),
		.Wr(MemData_Read));

	register MemDataReg
	
	 	(.clk(clk),
		.reset(rst),
		.regWrite(loadRegMemData), 
		.DadoIn(ReadData_Exit),
		.DadoOut(MemDataReg_Exit));

	mux_2in 

		(.SelMux2(SelMuxMem),
		.MuxA_a(AluOut_Exit),
		.MuxA_b(MemDataReg_Exit),
		.f_2in(MuxMem_Exit));


    
	

endmodule 
