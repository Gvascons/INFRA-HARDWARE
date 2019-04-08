 `timescale 1ps/1ps

module simulacao32;
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
	
	//Memoria32 meminst (.raddress(rdaddress), .waddress(wdaddress),
	//.Clk(clk), .Datain(data), .Dataout(q), .Wr(Wr));

	UP up(.rst(nrst), 
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
	nrst = 1'b0; 
	#(CLKPERIOD)
	nrst = 1'b1;
	#(CLKPERIOD)
	nrst = 1'b0;
	
end

always #(CLKDELAY) clk = ~clk;


endmodule 
