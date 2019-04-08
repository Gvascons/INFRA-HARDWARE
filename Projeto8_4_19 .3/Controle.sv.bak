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
	 output logic loadRegAluOut,
	 output logic SelMux2,
	 output logic SelMuxMem,
	 output logic RegWrite,
	 output logic loadRegMemData,
	 output logic MemData_Read,
	 output logic [31:0]INSTRUCTION,
	 output logic [1:0]SelMux4);

parameter SUM = 3'b001;
parameter SUB = 3'b010;
parameter LOAD = 3'b000;

Instr_Reg_RISC_V Instruction (.Instr31_0(INSTRUCTION));

enum logic [31:0] {RESET , SEARCH , WAIT32MEM, ESTADO, ADD_COMP, ADDI_COMP, SUBT_COMP, LOAD_DATA, LOAD_DATA_COMP, OP_CODE, STORE_DATA, STORE_DATA_COMP} state, nextState;

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
		case(INSTRUCTION[31:25]) // Pegando o funct7 para checar se é SUM ou SUB
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
        	     nextState = ADD_COMP;		
		     end
		
		     ADD_COMP: begin
		     SelMuxMem = 0;
		     RegWrite = 1;
		     nextState = RESET;
		     $stop;
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
        	     nextState = SUBT_COMP;
		     end
	
		     SUBT_COMP: begin
		     SelMuxMem = 0;
		     RegWrite = 1;
		     nextState = RESET;
		     $stop;
		     end
		endcase
		case(INSTRUCTION[14:12])
		     3'b000:begin	
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = SUM ;
        	     nextState = ADDI_COMP;
		     end
	
		     ADDI_COMP: begin
		     SelMuxMem = 0;
		     RegWrite = 1;
		     nextState = RESET;
		     $stop;
		     end

		     3'b011:begin
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = LOAD;
        	     nextState = LOAD_DATA;
		     end
	
		     LOAD_DATA: begin
		     MemData_Read = 1;
	             loadRegMemData = 1;
		     nextState = LOAD_DATA_COMP;
		     end
		
		     LOAD_DATA_COMP: begin
		     SelMuxMem = 1;
		     RegWrite = 1;
	             nextState = RESET;
		     $stop;
		     end
		  
		endcase
		case(OP_CODE[6:0])
		     7'b0100011:begin	
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = LOAD;
        	     nextState = STORE_DATA;
		     end
	
		     STORE_DATA: begin
		     MemData_Read = 1;
	             loadRegMemData = 1;
		     nextState = STORE_DATA_COMP;
		     end

		     //BEQ
		     7'1100011: begin	
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = SUB;
        	     nextState = BEQ_DATA;
		     end
	
		     BEQ_DATA: begin
		     MemData_Read = 1;
		     RegWrite = 0;
	             loadRegMemData = 1;
		     nextState = BEQ_DATA_COMP;
		     end

		     //BNE
		     7'1100111: begin	
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = BEQ;
        	     nextState = BEQ_DATA;
		     end
	
		     BEQ_DATA: begin
		     MemData_Read = 1;
		     RegWrite = 0;
	             loadRegMemData = 1;
		     nextState = BEQ_DATA_COMP;
		     end

		     //LUI
		     7'0110111: begin	
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = BEQ;
        	     nextState = BEQ_DATA;
		     end
	
		     BEQ_DATA: begin
		     MemData_Read = 1;
		     RegWrite = 0;
	             loadRegMemData = 1;
		     nextState = BEQ_DATA_COMP;
		     end

		endcase
	   end
	endcase 

	exitState = state;
end
endmodule 