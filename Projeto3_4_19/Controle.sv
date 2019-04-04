module Controle(
	 input logic clk,
	 input logic rst,
	 output logic PCwrite,
	 output logic IRwrite,
	 output logic [3-1:0] AluOperation,
	 output logic MemRead,
	 output logic exitState);

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
	     PCwrite = 0;
 	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = 3'bxxx;
             nextState = SEARCH;
	  end
	  SEARCH: begin
 	     PCwrite = 1;
	     MemRead = 0;
	     IRwrite = 0;
	     exitState = 0;
	     AluOperation = ADD;
             nextState = WAIT;
	  end
	
	   WAIT: begin
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