module UP

    	(input logic clk,
	 input logic rst,
	 input logic MemRead, 
     	 output logic PCwrite,
	 output logic IRwrite,
	 output logic [63:0] PCExit,
	 output logic [63:0] AluExit,
	 output logic [4:0]	i19_15,
	 output logic [4:0]	i24_20,
	 output logic [4:0]	i11_7,
	 output logic [6:0]	i6_0,
	 output logic [31:0] i31_0,
	 output logic [31:0] MemExit,
	 output logic exitState,
	 output logic [2:0] AluOperation);

	
	Controle UnitCtrl

       		(.clk(clk),
		.rst(rst),
		.PCwrite(PCwrite),
		.MemRead(MemRead),
		.AluOperation(AluOperation),
		.IRwrite(IRwrite),
		.exitState(exitState));

	Memoria32 MemoryInstruction

       		(.raddress(PCExit[31:0]),
		.Clk(clk),
		.Dataout(MemExit),
		.Wr(MemRead));

	ula64 Ula

       	        (.A(PCExit),
		.B(64'd4),
		.Seletor(AluOperation),
		.S(AluExit));

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

endmodule 
