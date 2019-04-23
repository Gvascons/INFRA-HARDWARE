module mux_3in
	(output logic [64-1:0] f_3in,
	input logic [64-1:0] MuxC_a,MuxC_b,MuxC_c,
	input logic [2:0]SelMux3);
always_comb
begin
    	case(SelMux3) 
		0: begin
		f_3in=MuxC_a;
		end 
		1: begin
		f_3in=MuxC_b;
		end
		2: begin
		f_3in=MuxC_c;
		end  
	endcase 
end
endmodule
