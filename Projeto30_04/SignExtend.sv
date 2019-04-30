module SignExtend (
	input logic [31:0] entrada,
     	output logic [63:0] saida);
 
	reg [31:0] immed;
	reg[6:0] aux;
 
	assign aux[6:0] = entrada[6:0];
 
	always_comb begin
    		if(aux == 7'b0010011 ||aux == 7'b0000011) begin // tipo I(ADDI, LD, SHIFT)
			if(entrada[14:12] == 3'b000 || entrada[14:12] == 3'b011) begin  // ADD LOAD
    				immed[11:0] = entrada[31:20];
        			saida [11:0] = immed [11:0];
        			if(immed[11] == 1) begin
            			saida [63:12] = 52'hfffffffffffff;
            			end
   
        			else begin
            			saida [63:12] = 52'h0000000000000;
            			end
			end
			if(entrada[14:12] == 3'b101 || entrada[14:12] == 3'b001) begin //SHIFT
				immed [5:0] = entrada [31:26];
				saida [5:0] = immed [5:0];
				if (immed[5] == 1) begin
				saida [63:8] = 56'hffffffffffffff;
				saida[7:6] = 2'b11;
            			end
  
        			else begin
            			saida [63:8] = 56'h00000000000000;
				saida[7:6] = 2'b00;
            			end
			end
     		end

    		if(aux == 7'b0100011) begin //tipo S(SD)
        		immed[4:0] = entrada[11:7];
        		immed[11:5]= entrada[31:25];
        		saida [11:0] = immed [11:0];
        		if(immed[11] == 1) begin
            			saida [63:12] = 52'hfffffffffffff;
            		end
   
        		else begin
            			saida [63:12] = 52'h0000000000000;
            		end
    		end
 
		if (aux == 7'b1100111) begin
			if(entrada[14:12] == 3'b000 ) begin //jalr
				immed[11:0] = entrada[31:20];
        			saida [11:0] = immed [11:0];
        			if(immed[11] == 1) begin
            				saida [63:12] = 52'hfffffffffffff;
            			end
   
        			else begin
            				saida [63:12] = 52'h0000000000000;
            			end
     			end

	        	if(entrada[14:12] == 3'b001 ) begin //bne
        			immed[12]=entrada[31];
        			immed[11]=entrada[7];
        			immed[10:5]=entrada[30:25];
        			immed[4:1]=entrada[11:8];
        			immed[0]=0;
        			if(immed[12] == 1) begin
            				saida [63:12] = 52'hfffffffffffff;
            			end
        			else
            			begin
            				saida [63:12] = 52'h0000000000000;
            			end
        		end
		end

        	if(aux==7'b1100011) //Tipo SB(beq)
    		begin
        		immed[12]=entrada[31];
        		immed[11]=entrada[7];
        		immed[10:5]=entrada[30:25];
        		immed[4:1]=entrada[11:8];
        		immed[0]=0;
        		saida [12:0] = immed [12:0];
        		if(immed[12] == 1)
            		begin
            			saida [63:12] = 52'hfffffffffffff;
            		end
   
        		else
            		begin
            			saida [63:12] = 52'h0000000000000;
            		end
        	end
 
        if(aux==7'b0110111) //Tipo U(lui)
    begin
	immed [11:0] = 12'h000;  
        immed [31:12]= entrada[31:12];
        saida [31:0] = immed [31:0];
        if(immed[31])
            begin
            saida [63:32] = 32'hffffffff;
            end
        else
            begin
            saida [63:32] = 32'h00000000;
            end
        end
 
 end
endmodule 