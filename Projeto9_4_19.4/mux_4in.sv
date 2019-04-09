module mux_4in
	(output logic [64-1:0] f_4in,
	input logic [64-1:0] MuxB_a,MuxB_b,MuxB_c,MuxB_d,
	input logic [1:0]SelMux4);
always_comb
begin
    	case(SelMux4) 
		0: begin
		f_4in=MuxB_a;
		end 
		1: begin
		f_4in=MuxB_b;
		end 
		2: begin
		f_4in=MuxB_c;
		end 
		3: begin
 		f_4in=MuxB_d;
		end 
	endcase 
end
endmodule
