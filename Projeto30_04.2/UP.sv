module UP (
	input logic clk,
	input logic rst,
	output logic MemRead, 
	output logic [2:0]SelMuxA,
	output logic [2:0]SelMuxB,
	output logic [2:0]SelMuxMem,
	output logic SelMuxAlu,
	output logic SelMuxPC,
     	output logic PCwrite,
	output logic LoadIR,
	output logic RegWrite,
	output logic loadRegA,
	output logic loadRegB,
	output logic loadRegMemData,
	output logic loadRegAluOut,
	output logic MemData_Read,	
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
	// output logic [63:0] ShiftExit,
	output logic [63:0] ShiftLeftExit,
	output logic [31:0] MemExit,
	output logic [63:0] MuxA_Exit,
	output logic [63:0] MuxB_Exit,
	output logic [63:0] MuxMem_Exit,
	output logic [63:0] MuxPC_Exit,
	output logic [63:0] MuxAlu_Exit,
	output logic [63:0] dataout1,
	output logic [63:0] dataout2,
	output logic [5:0] Num,
        output logic [1:0] Shift,
	output logic [2:0] AluOperation,
	output logic PCWriteCond,
	output logic AluZero,
	output logic AluMenor,
	output logic AluIgual);

	
	
	Controle UnitCtrl (
		.clk(clk),
		.rst(rst),
		.INSTR(i31_0), //
		.PCwrite(PCwrite), // PCwrite
		.MemRead(MemRead), // IMemRead
		.SelMuxA(SelMuxA), // AluSrcA
	        .SelMuxB(SelMuxB), // AluSrcB
		.SelMuxMem(SelMuxMem), //MemToReg
		.SelMuxAlu(SelMuxAlu), 
		.Shift(Shift), //SelShift
		.Num(Num), //N Shifts
		.AluOperation(AluOperation), //AluFct
		.LoadIR(LoadIR), //LoadIR
		.RegWrite(RegWrite), //WriteReg
		.loadRegA(loadRegA), //LoadRegA
		.loadRegB(loadRegB), //LoadRegB
		.AluZero(AluZero), //
		.AluMenor(AluMenor),
		.AluIgual(AluIgual), //
		.SelMuxPC(SelMuxPC), //PCSource
		.loadRegMemData(loadRegMemData), //LoadMDR
		.loadRegAluOut(loadRegAluOut), //LoadAOut
		.MemData_Read(MemData_Read), //DMemRead
		.PCWriteCond(PCWriteCond)); //PCWriteCond


	register PC (
		.clk(clk),
		.reset(rst),
		.regWrite(PCwrite),
		.DadoIn(MuxPC_Exit),
		.DadoOut(PCExit));


	Memoria32 MemoryInstruction (
		.raddress(PCExit[31:0]), 
		.Clk(clk),
		.Dataout(MemExit),
		.Wr(1'b0));


	Instr_Reg_RISC_V RegInstruction ( 
		.Clk(clk),
		.Reset(rst),
		.Load_ir(LoadIR),
		.Entrada(MemExit),
		.Instr19_15(i19_15),
		.Instr24_20(i24_20),
		.Instr11_7(i11_7),
		.Instr6_0(i6_0),
		.Instr31_0(i31_0));

	SignExtend sinalExt (
		.entrada(i31_0),
		.saida(SignExit));

/*
	Deslocamento ShiftDesloc (
		.In(SignExit),
 		.Num(i24_20),
		.Shift(Shift),
		.Out(ShiftExit)); 
*/	

	Deslocamento ShiftLeft (
		.In(SignExit),
 		.Num(6'd1),
		.Shift(2'd0),
		.Out(ShiftLeftExit));


	bancoReg Banco_Reg (
		.clock(clk),
		.regreader1(i19_15),
		.regreader2(i24_20),
		.regwriteaddress(i11_7),
		.datain(MuxMem_Exit), 
		.dataout1(dataout1),
		.dataout2(dataout2),
		.reset(rst),
		.write(RegWrite));


	register A (
		.clk(clk),
		.reset(rst),
		.regWrite(loadRegA),
		.DadoIn(dataout1),
		.DadoOut(RegA_Exit));


	register B (
		.clk(clk),
		.reset(rst),
		.regWrite(loadRegB), 
		.DadoIn(dataout2),
		.DadoOut(RegB_Exit));


	mux3_in MuxA (
		.SelMux3(SelMuxA),
		.MuxA_a(PCExit),
		.MuxA_b(RegA_Exit),
		.MuxA_c(64'd0),
		.f_3in(MuxA_Exit));


	mux8_in MuxB (
		.SelMux8(SelMuxB),
		.MuxB_a(RegB_Exit),
		.MuxB_b(64'd4),
		.MuxB_c(SignExit),
		.MuxB_d(ShiftLeftExit),
		.MuxB_e(/*ShiftExit*/),
		.MuxB_f(64'd0),
		.MuxB_g(AluOut_Exit),
		.MuxB_h(),
		.f_8in(MuxB_Exit));


	mux_2in MuxPC (
		.SelMux2(SelMuxPC),
		.MuxA_a(MuxAlu_Exit),
		.MuxA_b(AluOut_Exit),
		.f_2in(MuxPC_Exit));	


	ula64 Ula (
		.A(MuxA_Exit),
		.B(MuxB_Exit),
		.Seletor(AluOperation),
		.z(AluZero),
		.Igual(AluIgual),
		.S(AluExit),
		.Menor(AluMenor));
	

	register AluOut (
		.clk(clk),
		.reset(rst),
		.regWrite(loadRegAluOut), 
		.DadoIn(MuxAlu_Exit),
		.DadoOut(AluOut_Exit));


	Memoria64 MemoryData (
		.raddress(MuxAlu_Exit),
		.waddress(MuxAlu_Exit),
		.Clk(clk),
		.Datain(RegB_Exit),
		.Dataout(ReadData_Exit),
		.Wr(MemData_Read));


	register MemDataReg (
		.clk(clk),
		.reset(rst),
		.regWrite(loadRegMemData), 
		.DadoIn(ReadData_Exit),
		.DadoOut(MemDataReg_Exit));


	mux8_in MuxMem (
		.SelMux8(SelMuxMem),
		.MuxB_a(MuxAlu_Exit),
		.MuxB_b(MemDataReg_Exit),
		.MuxB_c(SignExit),
		.MuxB_d(),
		.MuxB_e(),
		.MuxB_f(),
		.MuxB_g(),
		.MuxB_h(),
		.f_8in(MuxMem_Exit));


	mux_2inAlu MuxAlu(
		.SelMux2(SelMuxAlu),
		.MuxA_a(AluExit),
		.MuxA_b(AluMenor),
		.f_2in(MuxAlu_Exit));	
endmodule 
