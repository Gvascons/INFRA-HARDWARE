 `timescale 1ps/1ps

module simulacao32;
/*
	logic PCwrite;
	logic IRwrite;
	logic [31:0] PCExit;
	logic [63:0] AluExit;
	logic [4:0]	i19_15;
	logic [4:0]	i24_20;
	logic [4:0]	i11_7;
	logic [6:0]	i6_0;
	logic [31:0] i31_0;
	logic [31:0] MemExit;
	logic exitState;
	logic clk;
	logic nrst;
	logic [3-1:0] AluOperation;
	reg [31:0]rdaddress;
	reg [31:0]wdaddress;
	reg [31:0]data;
	reg Wr;
	wire [3-1:0]q;
*/
	 logic clk;
	 logic rst;
	 logic MemRead; 
	 logic [2:0]SelMuxA;
	 logic [2:0]SelMuxB;
	 logic [2:0]SelMuxMem;
	 logic SelMuxAlu;
	 logic SelMuxPC;
     	 logic PCwrite;
	 logic LoadIR;
	 logic RegWrite;
	 logic loadRegA;
	 logic loadRegB;
	 logic loadRegMemData;
	 logic loadRegAluOut;
	 logic MemData_Read;
	 logic [63:0] PCExit;
	 logic [63:0] AluExit;
 	 logic [63:0] RegA_Exit;
	 logic [63:0] RegB_Exit;
 	 logic [63:0] AluOut_Exit;
	 logic [63:0] ReadData_Exit;
	 logic [63:0] MemDataReg_Exit;
	 logic [4:0] i19_15;
	 logic [4:0] i24_20;
	 logic [4:0] i11_7;
	 logic [6:0] i6_0;
	 logic [31:0] i31_0;
	 logic [63:0] SignExit;
	 logic [63:0] ShiftLeftExit;
	 logic [31:0] MemExit;
	 logic [63:0] MuxA_Exit;
	 logic [63:0] MuxB_Exit;
	 logic [63:0] MuxMem_Exit;
	 logic [63:0] MuxPC_Exit;
	 logic [63:0] MuxAlu_Exit;
	 logic [63:0]dataout1;
	 logic [63:0]dataout2;
	 logic [5:0] Num;
         logic [1:0] Shift;
	 logic [2:0] AluOperation;
	 logic AluZero;
	 //logic AluMenor;
	 logic AluMenor;
	 logic AluIgual;
	 logic PCWriteCond;
         logic LoadTYPE;
	 logic [63:0]LoadResultExit;
	//Memoria32 meminst (.raddress(rdaddress), .waddress(wdaddress),
	//.Clk(clk), .Datain(data), .Dataout(q), .Wr(Wr));
/*
	UP up(.rst(rst), 
	.clk(clk),
	.PCwrite(PCwrite), 
	.IRwrite(IRwrite), 
	.PCExit(PCExit), 
	.AluExit(AluExit), 
	.i19_15(i19_15),
	.i24_20(i24_20), 
	.i11_7(i11_7), 
	.i6_0(i6_0), 
	.i31_0(i31_0), 
	.MemExit(MemExit), 
	.AluOperation(q),
	.exitState(exitState),
	.MemRead(MemRead));
/*
*/
	UP up(
	   .clk(clk),
	   .rst(rst),
	   .MemRead(MemRead), 
	   .SelMuxA(SelMuxA),
	   .SelMuxB(SelMuxB),
	   .SelMuxMem(SelMuxMem),
	   .SelMuxPC(SelMuxPC),
	   .SelMuxAlu(SelMuxAlu),
     	   .PCwrite(PCwrite),
	   .LoadIR(LoadIR),
	   .RegWrite(RegWrite),
	   .loadRegA(loadRegA),
	   .loadRegB(loadRegB),
	   .loadRegMemData(loadRegMemData),
	   .loadRegAluOut(loadRegAluOut),
	   .MemData_Read(MemData_Read),	
	   .PCExit(PCExit),
	   .AluExit(AluExit),
 	   .RegA_Exit(RegA_Exit),
	   .RegB_Exit(RegB_Exit),
 	   .AluOut_Exit(AluOut_Exit),
	   .ReadData_Exit(ReadData_Exit),
	   .MemDataReg_Exit(MemDataReg_Exit),
	   .i19_15(i19_15),
	   .i24_20(i24_20),
	   .i11_7(i11_7),
	   .i6_0(i6_0),
	   .i31_0(i31_0),
	   .SignExit(SignExit),
	   .ShiftLeftExit(ShiftLeftExit),
	   // .ShiftExit(ShiftExit),
	   .MemExit(MemExit),
	   .MuxA_Exit(MuxA_Exit),
	   .MuxB_Exit(MuxB_Exit),
	   .MuxMem_Exit(MuxMem_Exit),
	   .MuxPC_Exit(MuxPC_Exit),
	   .MuxAlu_Exit(MuxAlu_Exit),
	   .dataout1(dataout1),
	   .dataout2(dataout2),
	   .Num(Num),
           .Shift(Shift),
	   .AluOperation(AluOperation),
	   .PCWriteCond(PCWriteCond),
	   //.AluMenor(AluMenor),
	   .AluMenor(AluMenor),
	   .AluZero(AluZero),
	   .AluIgual(AluIgual),
	   .LoadTYPE(LoadTYPE));


/*
	 Controle Controle(
	 .clk(clk),
	 .rst(rst),
	 .PCwrite(PCwrite),
	 .IRwrite(IRwrite),
	 .AluOperation(q),
	 .MemRead(MemRead),
	 .exitState(exitState));
*/


//gerador de clock e reset
localparam CLKPERIOD = 10000;
localparam CLKDELAY = CLKPERIOD / 2;

initial begin
	clk = 1'b1;
	rst = 1'b0; 
	#(CLKPERIOD)
	rst = 1'b1;
	#(CLKPERIOD)
	rst = 1'b0;
	
end

always #(CLKDELAY) clk = ~clk;


endmodule 
