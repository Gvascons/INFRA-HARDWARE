module Controle(
	 input logic clk,
	 input logic rst,
	 output logic PCwrite,
	 output logic IRwrite,
	 output logic [3-1:0] AluOperation,
	 output logic MemRead,
	 output logic exitState,
	 output logic loadRegA,
	 output logic loadRegB,
	 output logic SelMux2,
	 output logic [31:0]OPCODE,
	 output logic [1:0]SelMux4);

parameter SUM = 3'b001;
parameter SUB = 3'b010;

Instr_Reg_RISC_V Instruction (.Instr31_0(OPCODE))

enum logic [31:0] {RESET , SEARCH , WAIT32MEM, ESTADO, OPCODE} state, nextState;

always_ff @(posedge clk, posedge rst) 
begin
	if(rst)
	  state <= RESET;
	else
	  state <= nextState;
end

always_comb 
begin
	case(state)

	  RESET: begin
	     SelMux2 = 0;
	     SelMux4 = 0;
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = 3'bxxx;
             nextState = SEARCH;
	  end

	  SEARCH: begin
	     SelMux2 = 0;
	     SelMux4 = 0;
 	     PCwrite = 1;
	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = SUM;
             nextState = WAIT32MEM;
	  end

	   WAIT32MEM: begin
	     SelMux2 = 0;
	     SelMux4 = 1;
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 1;
	     exitState = 0;
	     AluOperation = SUM;
             nextState = ESTADO ; //Como saber qual vai ser o proximo estagio, ja que depende do tipo de instrucao
	   end
	
	 ESTADO: begin

	case(OPCODE[31:25]) // Pegando o funct3 para checar se é SUM ou SUB
	     7'b0000000: begin
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 1;
	     SelMux2 = 1;
	     SelMux4 = 0;
	     loadRegA = 1;
	     loadRegB = 1;
	     loadRegAluOut = 1;
	     exitState = 0;
	     AluOperation = SUM;
             nextState = ADD_EXE;
	   end
	
	   ADD_COMP: begin
	     SelMuxMem = 0;
	     RegWrite = 1;
	     nextState = RESET;
	  end
	
	     7'b0100000: begin
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 1;
	     SelMux2 = 1;
	     SelMux4 = 0;
	     loadRegA = 1;
	     loadRegB = 1;
	     loadRegAluOut = 1;
	     exitState = 0;
	     AluOperation = SUB;
             nextState = SUB_EXE;
	 end

	   SUB_COMP: begin
	     SelMuxMem = 0;
	     RegWrite = 1;
	     nextState = RESET;

        endcase 

	exitState = state;
end
endmodule 