module Controle(
    	input logic clk,
    	input logic rst,
    	input logic [31:0] INSTR,
	input logic AluZero,
    	input logic AluIgual,
	output logic [1:0]Shift,
	output logic [5:0]Num,
    	output logic PCwrite,
    	output logic LoadIR,
    	output logic [2:0] AluOperation,
    	output logic MemRead,
    	output logic loadRegA,
    	output logic loadRegB,
    	output logic loadRegAluOut,
    	output logic SelMux2,
    	output logic [2:0]SelMuxMem,
    	output logic RegWrite,
    	output logic PCWriteCond,
    	output logic loadRegMemData,
    	output logic MemData_Read,
    	output logic SelMuxPC,
    	output logic [1:0]SelMux4);
 	
    	parameter SUM = 3'b001; //1
    	parameter SUB = 3'b010; //2
    	parameter LOAD = 3'b000; //0
 	
    	//ESTADOS DA M�QUINA DE ESTADOS
    	parameter RESET = 20;
    	parameter FETCH = 21; 
    	parameter DECODE = 22; 
    	parameter sumOP1 = 4;
    	parameter sumOP2 = 5;  
    	parameter subOP1 = 6;
    	parameter subOP2 = 7; 
    	parameter beqOP1 = 8;
    	parameter bneOP1 = 10; 
    	parameter sumsubWrite1 = 11;
    	parameter sumsubWrite2 = 12;
    	parameter memDRead1 = 13;
    	parameter memDRead2 = 14;
	parameter loadWrite = 15;
    	parameter memDWrite1 = 16;
    	parameter memDWrite2 = 17;
    	parameter luiOP1 = 18;
	parameter luiOP2 = 19;
 
    	reg [5:0]state;
    	reg [5:0]nextState;
 
	always_ff @(posedge rst or posedge clk) begin
        	if (rst) begin
            		state = RESET;
        	end
		else begin
			state = nextState;
		end
	end

	always_comb begin
		case(state)
			RESET: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
    	        		SelMux4 = 0;
    	       			SelMuxMem = 0;
    	       			PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
    	      			MemRead = 0;
    	       			LoadIR = 0;
    	        		loadRegA = 0;
    	       			loadRegB = 0;
    	        		AluOperation = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				loadRegAluOut = 0;
    	        		nextState = FETCH;
			end

                	FETCH: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
			    	SelMux4 = 1;
			       	SelMuxMem = 1;
			    	PCwrite = 1;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 1;
			    	LoadIR = 1;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	AluOperation = SUM;
    	                    	nextState = DECODE;
                	end
 
                	DECODE: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
			    	SelMux4 = 3;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 1;
			    	LoadIR = 0;
			    	loadRegA = 1;
			    	loadRegB = 1;
				loadRegAluOut = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	AluOperation = SUM;
                        	
				case(INSTR[6:0])
					7'b0000000: begin
						nextState = FETCH; 
					end

					7'b0110011: begin   // Tipo R
                                		if (INSTR[31:25] == 7'b0000000) begin
							if (INSTR [14:12] = 3'b000) begin // add
							nextState = sumOP1;
						   end
							if (INSTR [14:12] = 3'b111) begin // and
							nextState = andOP1;
						   end
							if (INSTR [14:12] = 3'b010) begin // slt
							nextState = sltOP1;
						   end
                                		end
                        	        	if (INSTR[31:25] == 7'b0100000) begin // sub
                        	        		nextState = subOP1;
                        	        	end
					end
  
	
					7'b0010011: begin   // Tipo I 
						if (INSTR [14:12] = 3'b000) begin // addi
						nextState = sumsubWrite1;
					   end
						if (INSTR [14:12] = 3'b010) begin // slti
						nextState = sltiOP1;
					   end
						if (INSTR [14:12] = 3'b101) begin 
						   if (INSTR [31:26] = 6'b000000) // srli
						 nextState = srliOP1;
						end
						   if (INSTR [31:26] = 6'b010000) // srai
						 nextState = sraiOP1;
						end
					   end
						if (INSTR [14:12] = 3'b001) begin // slli
						nextState = slliOP1;
					   end

                        	    	end
					
					//jalr junto com o bne, blt e bge
					
					7'b0000011: begin  
						if (INSTR [14:12] = 3'b000) begin //lb
						nextState = lbOP1;
					    end
						if (INSTR [14:12] = 3'b001) begin //lh
						nextState = lhOP1;
					    end
						if (INSTR [14:12] = 3'b010) begin //lw
						nextState = lwOP1;
					    end
						if (INSTR [14:12] = 3'b011) begin //ld
						nextState = memDRead1;
					    end	
						if (INSTR [14:12] = 3'b100) begin //lbu
						nextState = lbuOP1;
					    end
						if (INSTR [14:12] = 3'b101) begin //lhu
						nextState = lhuOP1;
					    end
						if (INSTR [14:12] = 3'b110) begin //lwu
						nextState = lwuOP1;
					    end
					end  
					
					7'b0010011: begin  // nop
						nextState = nopOP1;
					end   
				
					7'b1110011: begin  // break
						nextState = breakOP1;
					end                
					
					
					7'b0100011: begin   // Tipo S (store)
						if (INSTR [14:12] = 3'b111) begin //sd
						nextState = memDWrite1; 
                        	    	   end	
						if (INSTR [14:12] = 3'b010) begin //sw
						nextState = swOP1; 
                        	    	   end	
						if (INSTR [14:12] = 3'b001) begin //sh
						nextState = shOP1; 
                        	    	   end
						if (INSTR [14:12] = 3'b000) begin //sb
						nextState = sbOP1; 
                        	    	   end
					end

					7'b1100011: begin   // Tipo SB (beq)
                        	                nextState = beqOP1;
                        	    	end
	
					7'b1100111: begin   // Tipo SB + jalr
						if (INSTR [14:12] = 3'b000) begin //jalr
						nextState = jalrOP1;
					     end
						if (INSTR [14:12] = 3'b001) begin //bne
						nextState = bneOP1;
					     end
						if (INSTR [14:12] = 3'b101) begin  //bge
						nextState = bgeOP1;
					     end
						if (INSTR [14:12] = 3'b100) begin  //blt
						nextState = bltOP1;
					     end

                        	        end

					7'b0110111: begin // Tipo U (lui)
						nextState = luiOP1;
					end

					7'b1101111: begin // Tipo UJ (jal)
						nextState = jalOP1;
					end
				endcase
			end

			sumOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 1;
			    	SelMux4 = 0;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	AluOperation = SUM;
				nextState = sumOP2;
			end
                                        
			sumOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 1;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	//AluOperation = 0;
				nextState = RESET;
			end
			
			subOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 1;
			    	SelMux4 = 0;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	AluOperation = SUB;
				nextState = subOP2;
			end

			subOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 1;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	//AluOperation = 0;
				nextState = RESET;
			end

			beqOP1: begin
				Shift = 0;
				SelMux2 = 1;
			    	SelMux4 = 0;
			       	SelMuxMem = 1;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = SUB;
                                case (AluZero) 
					1: begin
						PCwrite = 1;
					    	SelMuxPC = 1;
					    	PCWriteCond = 1;
                                   	end
                                        0: begin
                                            	PCwrite = 0;
                                            	PCWriteCond = 0;
					end
				endcase
				nextState = RESET;
			end
          
			bneOP1: begin
				Shift = 0;
				SelMux2 = 1;
			    	SelMux4 = 0;
			       	SelMuxMem = 1;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = SUB;
                                case (AluZero) 
					0: begin
						PCwrite = 1;
					    	SelMuxPC = 1;
					    	PCWriteCond = 1;
                                   	end
                                        1: begin
                                            	PCwrite = 0;
                                            	PCWriteCond = 0;
					end
				endcase
				nextState = RESET;
			end

			sumsubWrite1: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 1;
    	        		SelMux4 = 2;
    	       			SelMuxMem = 0;
    	       			PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
    	      			MemRead = 0;
    	       			LoadIR = 0;
    	        		loadRegA = 0;
    	       			loadRegB = 0;
    	        		AluOperation = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				loadRegAluOut = 1;
    	        		nextState = sumsubWrite2;
			end

			sumsubWrite2: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 1;
			    	SelMux4 = 2;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	AluOperation = SUM;
				nextState = RESET;
                 	end
			
			memDRead1: begin
				Shift = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 1;
			    	SelMux4 = 2;
			       	SelMuxMem = 1;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	//loadRegA = 0;
			    	//loadRegB = 0;
				loadRegAluOut = 1;
				loadRegMemData = 0;
				nextState = memDRead2;
			end

			memDRead2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 0;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	//loadRegA = 0;
			    	//loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 1;
			    	//AluOperation = 0;
				nextState = loadWrite;
			end

			loadWrite: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 0;
			       	SelMuxMem = 1;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	//AluOperation = 0;
				nextState = RESET;
			end

			memDWrite1: begin
				Shift = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 1;
			    	SelMux4 = 2;
			       	SelMuxMem = 1;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	//loadRegA = 0;
			    	//loadRegB = 0;
				loadRegAluOut = 1;
				loadRegMemData = 0;
				nextState = memDWrite2;
			end

			memDWrite2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 0;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 1;
			    	LoadIR = 0;
			    	//loadRegA = 0; 
			    	//loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	//AluOperation = 0;
				nextState = RESET;
			end
			
			luiOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMux2 = 0;
			    	//SelMux4 = 2;
			       	//SelMuxMem = 2;
			    	PCwrite = 0;
				PCWriteCond = 0;
				//RegWrite = 1;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	//AluOperation = 0;
				nextState = luiOP2;
			end 

			luiOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
			    	SelMux4 = 2;
			       	SelMuxMem = 2;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = 0;
				nextState = RESET;
			end 
            	endcase
        end
endmodule
