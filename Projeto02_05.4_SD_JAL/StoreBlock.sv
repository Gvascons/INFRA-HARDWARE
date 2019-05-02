module StoreBlock(
	input logic [63:0]Entrada,
	input logic [63:0]RegBIn_Mem,
	input logic [2:0]StoreTYPE,
	output logic [63:0]StoreResult);
	
	always_comb begin
		case (StoreTYPE)
			1:begin // sd
				StoreResult = RegBIn_Mem;
			end
			2:begin // sw
				StoreResult[31:0] = RegBIn_Mem[31:0];
				StoreResult[63:32] = Entrada[63:32];
			end
			3:begin // sh
				StoreResult[15:0] = RegBIn_Mem[15:0];
				StoreResult[63:16] = Entrada[63:16];
			end
			4:begin // sb
				StoreResult[7:0] = RegBIn_Mem[7:0];
				StoreResult[63:8] = Entrada[63:8];
			end
			default: begin
				
			end
		endcase	

	end
endmodule //StoreBlock





