module Controle(
	 input logic clk,
	 input logic rst,
	 input logic [31:0] INSTR,
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
	 output logic PCWriteCond,
	 output logic z,
	 output logic loadRegMemData,
	 output logic MemData_Read,
	 output logic SelMuxPC,
	 output logic [1:0]SelMux4);

parameter SUM = 3'b001;
parameter SUB = 3'b010;
parameter LOAD = 3'b000;

Instr_Reg_RISC_V Instruction (.Instr31_0(INSTR));

enum logic [31:0] {RESET , FETCH , DECODE, ESTADO, ADD_COMP, ADDI_COMP, SUBT_COMP, LOAD_DATA, LOAD_DATA_COMP, OP_COMP, STORE_DATA, STORE_DATA_COMP} state, nextState;

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
             nextState = FETCH;
	  end

	  FETCH: begin
	     SelMux2 = 0;
	     SelMux4 = 1;
 	     PCwrite = 1;
	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = SUM;
             nextState = DECODE;
	     SelMuxPC = 0;
	  end

	   DECODE: begin
	     SelMux2 = 0;
	     SelMux4 = 3;
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 1;
	     exitState = 0;
	     AluOperation = SUM;
             nextState = ESTADO ; //Como saber qual vai ser o proximo estagio, ja que depende do tipo de instrucao
	   end
	
	   ESTADO: begin
		case(INSTR[6:0]) 
		     7'b0110011: begin  // Tipo R
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 0;
		     loadRegA = 1;
		     loadRegB = 1;
		     exitState = 0;
		     case (INSTR[31:25])
		     	7'b0000000: begin
		     	AluOperation = SUM;
		     	loadRegAluOut = 1;
                     	end
		     	7'b0100000: begin
        	     	AluOperation = SUB;
		    	loadRegAluOut = 1;
			PCWriteCond = 0;
		    	 end	
                      endcase
                     nextState = OP_COMP;
		     end
		
		     OP_COMP: begin
		     SelMuxMem = 0;
		     RegWrite = 1;
		     nextState = FETCH;
		     end
			
		
		     7'b0010011:begin	// Tipo I (addi)
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
		     nextState = FETCH;
		     end

		     7'b0000011:begin  // Tipo I (load)
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
	             nextState = FETCH;
		     end
		  
		
		     7'b0100011: begin	// Tipo S (store)
		     PCwrite = 0;
 		     MemRead = 0;
		     IRwrite = 1;
		     SelMux2 = 1;
		     SelMux4 = 2;
		     loadRegA = 1;
		     loadRegB = 0;
		     loadRegAluOut = 1;
		     exitState = 0;
		     AluOperation = SUM;
        	     nextState = STORE_DATA;
		     end
	
		     STORE_DATA: begin
		     MemData_Read = 1;
	             loadRegMemData = 1;
		     nextState = FETCH;
		     end

		     
		     7'b1100011: begin	   // Tipo SB (BEQ)
		     SelMux2 = 1;
		     SelMux4 = 0;
		     AluOperation = SUB;
		     PCWriteCond = 1;
		     SelMuxPC = 1;
		     nextState = FETCH;
		     end
	

		     7'b1100111: begin	 // Tipo SB (BNE)
		     SelMux2 = 1;
		     SelMux4 = 0;
		     AluOperation = SUB;
		     SelMuxPC = 1;
		     PCWriteCond = 0;
		     if (z == 1)
		      begin
		      PCwrite = 0;
		      end
		     nextState = FETCH;
		     end

		     
		/*    7'b0110111: begin	// Tipo U (LUI)
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
		     end */

		endcase
	   end
	endcase 

	exitState = state;
end
endmodule 