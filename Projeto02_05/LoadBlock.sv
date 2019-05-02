module LoadBlock(
	input logic [63:0]Entrada,
	input logic [2:0]LoadTYPE,
	output logic [63:0]LoadResult);
	
	always_comb begin
		case(LoadTYPE)
			//LD
			1:begin
				LoadResult = Entrada;
			end		
			//LW
			2: begin
				if(Entrada[31] == 0) begin
					LoadResult = {32'b0, Entrada[31:0]};
				end
				else begin
					LoadResult = {32'hFFFFFFFF, Entrada[31:0]};
				end
			end
			//LH
			3: begin
				if(Entrada[15] == 0)
					LoadResult = {48'b0,Entrada[15:0]};
				else
					LoadResult={48'hFFFFFFFFFFFF,Entrada[15:0]};
			end
			//LB		
			4: begin
				if(Entrada[7] == 0)
					LoadResult = {56'b0,Entrada[7:0]};
				else
					LoadResult = {56'hFFFFFFFFFFFFFF, Entrada[7:0]};
			end
			//LWU
			5: begin
				LoadResult = {32'b0,Entrada[31:0]};
			end
	
			//LHU
			6: begin
				LoadResult = {48'b0,Entrada[15:0]};
			end
	
			7: begin
				LoadResult = {56'b0,Entrada[7:0]};
			end
		endcase	
	end
endmodule // LoadBlock




