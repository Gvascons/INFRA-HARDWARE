module Controle(
    input logic clk,
    input logic rst,
    input logic [31:0] INSTR,
    output logic PCwrite,
    output logic LoadIR,
    output logic [2:0] AluOperation,
    output logic MemRead,
    output logic [5:0] exitState,
    output logic loadRegA,
    output logic loadRegB,
    output logic loadRegAluOut,
    output logic SelMux2,
    //output logic [2:0]SelMux3,
    output logic [2:0]SelMuxMem,
    output logic RegWrite,
    output logic PCWriteCond,
    output logic loadRegMemData,
    output logic MemData_Read,
    output logic SelMuxPC,
    output logic AluZero,
    output logic AluIgual,
    output logic [1:0]SelMux4);
 
    parameter SUM = 3'b001; //1
    parameter SUB = 3'b010; //2
    parameter LOAD = 3'b000; //0
 
    //ESTADOS DA M�QUINA DE ESTADOS
    parameter RESET1 = 20;
    parameter RESET2 = 21; 
    parameter FETCH = 22; 
    parameter DECODE = 3; 
    parameter sumOP1 = 4;
    parameter sumOP2 = 5;  
    parameter subOP1 = 6;
    parameter subOP2 = 7; 
    parameter beqOP1 = 8;
    parameter bneOP1 = 10; 
    parameter sumsubWrite1 = 12;
    parameter sumsubWrite2 = 13;
    parameter memDRead1 = 14;
    parameter memDRead2 = 15;
    parameter memDWrite1 = 16;
    parameter memDWrite2 = 17;
    parameter loadWrite = 18;
    parameter lui = 19;
 
    reg [5:0]state;
    reg [5:0]nextState;
 
	always_ff @(posedge rst or posedge clk) begin
        	if (rst) begin
            		state = RESET1;
        	end
		else begin
			state = nextState;
		end
	end

	always_comb begin
		case(state)
	
		RESET1: begin
			SelMux2 = 0;
            		SelMux4 = 0;
           		SelMuxMem = 0;
           		PCwrite = 0;
          		MemRead = 0;
           		LoadIR = 0;
           		exitState = 0;
            		loadRegA = 0;
           		loadRegB = 0;
            		AluOperation = 0;
            		AluZero = 0;
            		nextState = FETCH;
		end

		RESET2: begin
			SelMux2 = 0;
            		SelMux4 = 0;
           		SelMuxMem = 0;
           		PCwrite = 0;
			RegWrite = 0;
          		MemRead = 0;
           		LoadIR = 0;
           		exitState = 0;
            		loadRegA = 0;
           		loadRegB = 0;
            		AluOperation = 0;
            		AluZero = 0;
            		nextState = FETCH;
		end

                FETCH: begin
                        SelMuxPC = 0;
                        SelMux2 = 0;
                        SelMux4 = 1;
                        SelMuxMem = 1;
                        PCwrite = 1;
                        MemRead = 1;
                        LoadIR = 1;
                        loadRegAluOut = 0;
                        exitState = 1;
                        AluOperation = SUM;
                        nextState = DECODE;
                end
 
                DECODE: begin
                        SelMuxPC = 0;
                        SelMux2 = 0;
                        SelMux4 = 3;
                    	loadRegA = 1;
                        loadRegB = 1;
                        PCwrite = 0;
                        SelMuxMem = 0;
                        MemRead = 1;
                        LoadIR = 0;
                        loadRegAluOut = 1;
                        exitState = 2;
                        AluOperation = SUM;
       
			case(INSTR[6:0])
				7'b0000000:
				nextState = RESET2; 
				7'b0110011: begin   // Tipo R
                                	if (INSTR[31:25] == 7'b0000000) begin
						nextState = sumOP1;
                                	end
                                	if (INSTR[31:25] == 7'b0100000) begin
                                		nextState = subOP1;
                                	end
				end

				7'b0000011: begin   // Tipo S (load)
					nextState = memDRead1;
				end               

				7'b0010011: begin   // Tipo I (addi)
					nextState = sumsubWrite1;
                            	end

				7'b0100011: begin   // Tipo I (store)
					nextState = memDWrite1; //calcula o OFFSET para o LOAD, STORE, E ADDI
                            	end

				7'b1100011: begin   // Tipo SB (beq)
                                        nextState = beqOP1;

                            	end

				7'b1100111: begin   // Tipo SB (bne)
					nextState = bneOP1;

                                end

				7'b0110111: begin // lui
					nextState = lui;
				end
			endcase
		end

			sumOP1:begin
				SelMux2 = 1;
				SelMux4 = 0;
				exitState = 3;
				AluOperation = SUM;
				loadRegAluOut = 1;
				nextState = sumOP2;
			end
                                        
			sumOP2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 0;
				RegWrite = 1;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = RESET2;
			end
			
			subOP1:begin
				SelMux2 = 1;
				SelMux4 = 0;
				exitState = 4;
				AluOperation = SUB;
				loadRegAluOut = 1;
				nextState = subOP2;
			end

			subOP2:  begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 1;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 0;
				RegWrite = 1;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = RESET2;
			end

			beqOP1: begin
				SelMux2 = 1;
				SelMux4 = 0;
				exitState = 5;
                                        case (AluIgual) 
					1 : begin
                                            PCwrite = 1;
					    SelMuxPC = 1;
					    PCWriteCond = 1;
                                   	end
                                        0 : begin
                                            PCwrite = 0;
                                            PCWriteCond = 0;
					end
					endcase
					nextState = RESET2;

			end
                                        
			bneOP1: begin
				SelMux2 = 1;
				SelMux4 = 0;
				AluOperation =SUB;
				exitState = 6;                                    
                                        if (AluZero == 0) begin
                                        	PCwrite = 1;
						SelMuxPC = 1; 
						PCWriteCond = 0;
                                   	end
                                        if (AluZero == 1) begin
                                        	PCwrite = 0;
                                        	PCWriteCond = 0;
					end
					nextState = RESET2;
			end
			
			sumsubWrite1: begin
			 	AluOperation = SUM;
                                exitState = 0;
				loadRegAluOut = 1;
                                PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 1;
				SelMux4 = 2;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =1;
				RegWrite = 0;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = sumsubWrite2;
			end

			sumsubWrite2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 1;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 0;
				RegWrite = 1;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = RESET2;
                 	end
			
			memDRead1: begin
				exitState = 0;
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 1;
				SelMux4 = 2;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 0;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = memDRead2;
			end

			memDRead2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =0;
				RegWrite = 0;
				SelMuxMem = 1;
				loadRegMemData = 1;
				MemData_Read = 1;
				MemRead = 0;
				LoadIR = 0;
				nextState = loadWrite;
			end

			memDWrite1: begin
				SelMux2 = 1;
				SelMux4 = 2;
                                AluOperation = SUM;
                                exitState = 0;
				loadRegAluOut = 1;
                                PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 1;
				SelMux4 = 2;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =1;
				RegWrite = 0;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = memDWrite2;
			end

			memDWrite2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =0;
				RegWrite = 0;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 1;
				MemRead = 0;
				LoadIR = 0;
				nextState = RESET2;

			end

			loadWrite: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 0;
				RegWrite = 1;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				nextState = RESET2;
			end
			
			lui: begin
				PCwrite = 0;
				RegWrite = 1;
				SelMux2 = 0;
				SelMuxMem = 2;
				SelMux4 = 2;
				loadRegA = 0;
				loadRegB = 0;
				exitState = 7;
				nextState = RESET2;
				end 
 
            	endcase

        end
endmodule
