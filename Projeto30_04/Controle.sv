module Controle(
    	input logic clk,
    	input logic rst,
    	input logic [31:0] INSTR,
	input logic AluZero,
	input logic AluMenor,
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
    	output logic [2:0]SelMuxA,
	output logic SelMuxAlu,
    	output logic [2:0]SelMuxMem,
    	output logic RegWrite,
    	output logic PCWriteCond,
    	output logic loadRegMemData,
    	output logic MemData_Read,
    	output logic SelMuxPC,
    	output logic [2:0]SelMuxB);
 	
    	parameter SUM = 3'b001; //1
    	parameter SUB = 3'b010; //2
    	parameter LOAD = 3'b000; //0
	parameter AND = 3'b011; //3
 	
    	//ESTADOS DA M�QUINA DE ESTADOS
    	parameter RESET = 4;
    	parameter FETCH = 5; 
    	parameter DECODE = 6; 
    	parameter sumOP = 7;
    	//parameter sumOP2 = 5;
    	parameter subOP = 8;
    	//parameter subOP2 = 7; 
    	parameter beqOP1 = 9;
    	parameter bneOP1 = 10; 
    	parameter addiOP1 = 11;
    	parameter addiOP2 = 12;
    	parameter ldOP1 = 13;
    	parameter ldOP2 = 14;
	parameter loadWrite = 15;
    	parameter sdOP1 = 16;
    	parameter sdOP2 = 17;
    	parameter luiOP1 = 18;
	parameter luiOP2 = 19;
	parameter andOP = 20;
	parameter sltOP = 21;
	parameter sltiOP = 22;
	parameter wreg_op = 23;
	parameter jalrOP1 = 24;
	parameter jalrOP2 = 25;
	parameter jalrOP3 = 26; 
	parameter jalrOP4 = 27;
	parameter srliOP1 = 28;
	parameter sraiOP1 = 29;
	parameter slliOP1 = 30;
	parameter lbOP1 = 31;
 	parameter lhOP1 = 32;
	parameter lwOP1 = 33;
	parameter lbuOP1 = 34;
	parameter lhuOP1 = 35;
	parameter lwuOP1 = 36;
	parameter nopOP1 = 37;
	parameter breakOP1 = 38;
	parameter swOP1 = 39;
	parameter shOP1 = 40;
	parameter sbOP1 = 41;
	parameter bgeOP1 = 42;
	parameter bltOP1 = 43;
	parameter jalOP1 = 44;
	parameter jalOP2 = 45;
	parameter jalOP3 = 46;
 
    	reg [9:0]Estado;
    	reg [9:0]nextState;
 
	always_ff @(posedge rst or posedge clk) begin
        	if (rst) begin
            		Estado = RESET;
        	end
		else begin
			Estado = nextState;
		end
	end

	always_comb begin
		case(Estado)
			RESET: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 0;
    	        		SelMuxB = 0;
				SelMuxAlu = 0;
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
				SelMuxA = 0;
			    	SelMuxB = 1;
				SelMuxAlu = 0;
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
				SelMuxA = 0;
			    	SelMuxB = 3;
				SelMuxAlu = 0;
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
							if (INSTR [14:12] == 3'b000) begin // add
								nextState = sumOP;
						   	end
							if (INSTR [14:12] == 3'b111) begin // and
								nextState = andOP;
						   	end
							if (INSTR [14:12] == 3'b010) begin // slt
								nextState = sltOP;
						   	end
                                		end
                        	        	if (INSTR[31:25] == 7'b0100000) begin // sub
                        	        		nextState = subOP;
                        	        	end
					end
  
	
					7'b0010011: begin   // Tipo I 
						if (INSTR [14:12] == 3'b000) begin // addi
							nextState = addiOP1;
					   	end
						if (INSTR [14:12] == 3'b010) begin // slti
							nextState = sltiOP;
					   	end
						if (INSTR [14:12] == 3'b101) begin 
						   	if (INSTR [31:26] == 6'b000000) begin// srli
						 		nextState = srliOP1;
							end
						   	if (INSTR [31:26] == 6'b010000) begin // srai
						 		nextState = sraiOP1;
							end
					   	end
						if (INSTR [14:12] == 3'b001) begin // slli
							nextState = slliOP1;
					   	end
                        	    	end
					
					//jalr junto com o bne, blt e bge
					
					7'b0000011: begin  
						if (INSTR [14:12] == 3'b000) begin //lb
							nextState = lbOP1;
					    	end
						if (INSTR [14:12] == 3'b001) begin //lh
							nextState = lhOP1;
					    	end
						if (INSTR [14:12] == 3'b010) begin //lw
							nextState = lwOP1;
					    	end
						if (INSTR [14:12] == 3'b011) begin //ld
							nextState = ldOP1;
					    	end	
						if (INSTR [14:12] == 3'b100) begin //lbu
							nextState = lbuOP1;
					    	end
						if (INSTR [14:12] == 3'b101) begin //lhu
							nextState = lhuOP1;
					    	end
						if (INSTR [14:12] == 3'b110) begin //lwu
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
						if (INSTR [14:12] == 3'b111) begin //sd
							nextState = sdOP1; 
                        	    	   	end	
						if (INSTR [14:12] == 3'b010) begin //sw
							nextState = swOP1; 
                        	    	   	end	
						if (INSTR [14:12] == 3'b001) begin //sh
							nextState = shOP1; 
                        	    	   	end
						if (INSTR [14:12] == 3'b000) begin //sb
							nextState = sbOP1; 
                        	    	   	end
					end

					7'b1100011: begin   // Tipo SB (beq)
                        	                nextState = beqOP1;
                        	    	end
	
					7'b1100111: begin   // Tipo SB + jalr
						if (INSTR [14:12] == 3'b000) begin //jalr
							nextState = jalrOP1;
					     	end
						if (INSTR [14:12] == 3'b001) begin //bne
							nextState = bneOP1;
					     	end
						if (INSTR [14:12] == 3'b101) begin  //bge
							nextState = bgeOP1;
					    	end
						if (INSTR [14:12] == 3'b100) begin  //blt
							nextState = bltOP1;
					     	end

                        	        end

					7'b0110111: begin // Tipo U (lui)
						nextState = luiOP1;
					end

					7'b1101111: begin // Tipo UJ (jal)
						nextState = jalOP1;
					end
				endcase //case(INSTR[6:0])
			end //DECODE
//INICIO DO TIPO R
			sumOP: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
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
				nextState = wreg_op;
			end
                                        

			andOP: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
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
			    	AluOperation = AND;
				nextState = wreg_op;
			end
                                        
			subOP: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
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
				nextState = wreg_op;
			end

			sltOP: begin
				Shift = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
				SelMuxAlu = 1;
			       	SelMuxMem = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = LOAD;
				nextState = wreg_op;
			end

			sltiOP: begin
				Shift = 0;
				SelMuxA = 1;
			    	SelMuxB = 2;
				SelMuxAlu = 1;
			       	SelMuxMem = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = LOAD;
				nextState = wreg_op;
			end

			wreg_op: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 0;
			    	//SelMuxB = 1;
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
//FIM DO TIPO R

//TIPO I

			addiOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
    	        		SelMuxB = 2;
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
    	        		nextState = addiOP2;
			end

			addiOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 2;
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

			jalrOP1: begin 
				Shift = 0;
				SelMuxPC = 1;
				SelMuxA = 0;
			    	SelMuxB = 5;
			       	//SelMuxMem = 0;
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
				nextState = jalrOP3;
			end

			jalrOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 1;
			    	SelMuxB = 3;
			       	SelMuxMem = 0;
			    	PCwrite = 1;
				PCWriteCond = 0;
				RegWrite = 1;
			    	MemRead = 0;
			    	LoadIR = 0;
			    	loadRegA = 1;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
			    	//AluOperation = 0;
				nextState = jalrOP3;
			end

			jalrOP3: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 3;
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
				nextState = jalrOP4;
			end

			jalrOP4: begin 
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 0;
			    	SelMuxB = 6;
			       	SelMuxMem = 0;
			    	PCwrite = 1;
				PCWriteCond = 0;
				RegWrite = 0;
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

			lbOP1: begin

			end

			lhOP1: begin

			end

			lwOP1: begin

			end

			ldOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMuxA = 1;
			    	SelMuxB = 2;
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
				nextState = ldOP2;
			end

			ldOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 0;
			    	//SelMuxB = 0;
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
				//SelMuxA = 0;
			    	//SelMuxB = 0;
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

			lbuOP1: begin

			end

			lhuOP1: begin


			end

			lwuOP1: begin


			end

			nopOP1: begin


			end

			breakOP1: begin


			end
			
//FIM DO TIPO I

//INICIO DO TIPO I(Shifts)

			srliOP1: begin //SHIFT RIGHT LOGICO
				Shift = 2'b01;
				SelMuxPC = 0;
				//SelMuxA = 1;
			    	//SelMuxB = 4;
			       	SelMuxMem = 0;
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
			    	AluOperation = LOAD;
				nextState = RESET;
			end

			sraiOP1: begin //SHIFT RIGHT ARITMETICO
				Shift = 2'b10;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 4;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = LOAD;
				nextState = RESET;
			end

			slliOP1: begin //SHIFT LEFT LOGICO
				Shift = 2'b00;
				SelMuxPC = 0;
				SelMuxA = 1;
			    	SelMuxB = 4;
			       	SelMuxMem = 0;
			    	PCwrite = 0;
				PCWriteCond = 0;
				RegWrite = 0;
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


//FIM DO TIPO I(Shifts)

//INICIO DO TIPO S
			
			sdOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMuxA = 1;
			    	SelMuxB = 2;
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
				nextState = sdOP2;
			end

			sdOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 0;
			    	//SelMuxB = 0;
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

			swOP1: begin


			end

			shOP1:begin

			end

			sbOP1: begin


			end

//FIM DO TIPO S

//INICIO DO TIPO SB

			beqOP1: begin
				Shift = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
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
				SelMuxA = 1;
			    	SelMuxB = 0;
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

			bgeOP1: begin
				Shift = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
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
                                case (!AluMenor) 
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

			bltOP1: begin
				Shift = 0;
				SelMuxA = 1;
			    	SelMuxB = 0;
			       	SelMuxMem = 1;
				RegWrite = 0;
			    	MemRead = 0;
				MemData_Read = 0;
			    	LoadIR = 0;
			    	loadRegA = 0;
			    	loadRegB = 0;
				loadRegAluOut = 0;
				loadRegMemData = 0;
			    	AluOperation = LOAD;
                                case (AluMenor) 
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
			
//FIM DO TIPO SB
//INICIO DO TIPO U

			luiOP1: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 0;
			    	//SelMuxB = 2;
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
				SelMuxA = 0;
			    	SelMuxB = 2;
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
//FIM DO TIPO U	
		
//INICIO DO TIPO UJ	

			jalOP1: begin
				Shift = 0;
				SelMuxPC = 1;
				SelMuxA = 0;
			    	SelMuxB = 5;
			       	//SelMuxMem = 0;
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
				nextState = jalOP2;
			end

			jalOP2: begin
				Shift = 0;
				SelMuxPC = 0;
				SelMuxA = 2;
			    	SelMuxB = 3;
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
				nextState = jalOP3;
			end

			jalOP3: begin
				Shift = 0;
				SelMuxPC = 0;
				//SelMuxA = 2;
			    	SelMuxB = 0;
			       	SelMuxMem = 6;
			    	PCwrite = 1;
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
				nextState = RESET;
				
			end
//FIM DO TIPO UJ

            	endcase //case(state)
        end
endmodule
