module mux_2in
	(output logic [64-1:0] f_2in,
	input logic [64-1:0] MuxA_a,MuxA_b,
	input logic [1:0]sel);
always_comb
begin
    	case(sel) 
		0: begin
		f_2in=MuxA_a;
		end 
		1: begin
		f_2in=MuxA_b;
		end 
	endcase 
end
endmodule
