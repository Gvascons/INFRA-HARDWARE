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
	 output logic [1:0]SelMux4);

parameter ADD = 3'b001;

enum logic [5:0] {RESET , SEARCH , WAIT} state, nextState;

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
	     SelMux4 = 1;
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = 3'bxxx;
             nextState = SEARCH;
	  end
	  SEARCH: begin
	     SelMux2 = 1;
	     SelMux4 = 0;
 	     PCwrite = 1;
	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = ADD;
             nextState = WAIT;
	  end
	   WAIT: begin
	     SelMux2 = 1;
	     SelMux4 = 0;
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 1;
	     exitState = 0;
	     AluOperation = ADD;
             nextState = SEARCH;
	   end
	
        endcase 
	exitState = state;
end
endmodule 