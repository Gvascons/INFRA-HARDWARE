module Controle(
    input logic clk,
    input logic rst,
    input logic [31:0] INSTR,
    output logic PCwrite,
    output logic LoadIR,
    output logic [2:0] AluOperation,
    output logic MemRead,
    output logic exitState,
    output logic loadRegA,
    output logic loadRegB,
    output logic loadRegAluOut,
    output logic SelMux2,
    output logic SelMuxMem,
    output logic RegWrite,
    output logic PCWriteCond,
    output logic loadRegMemData,
    output logic MemData_Read,
    output logic SelMuxPC,
    output logic AluZero,
    output logic [1:0]SelMux4);
 
    parameter SUM = 3'b001;
    parameter SUB = 3'b010;
    parameter LOAD = 3'b000;
 
    //ESTADOS DA M�QUINA DE ESTADOS
    parameter RESET = 1; 
    parameter FETCH = 2; 
    parameter DECODE = 3; 
    parameter sumOP1 = 4;
    parameter sumOP2 = 5;  
    parameter subOP1 = 6;
    parameter subOP2 = 7; 
    parameter beqOP1 = 8;
    parameter beqOP2 = 9; 
    parameter bneOP1 = 10;
    parameter bneOP2 = 11; 
    parameter sumsubWrite1 = 12;
    parameter sumsubWrite2 = 13;
    parameter memDRead1 = 14;
    parameter memDRead2 = 15;
    parameter memDWrite1 = 16;
    parameter memDWrite2 = 17;
    parameter loadWrite = 18;
 
    reg [5:0]state;
 
    always_ff @(posedge rst or posedge clk) begin
        if (rst) begin
            SelMux2 = 0;
            SelMux4 = 0;
            SelMuxMem = 0;
            PCwrite = 0;
            MemRead = 0;
            LoadIR = 0;
            exitState = 0;
            loadRegA = 0;
            loadRegB = 0;
            AluOperation = 3'bxxx;
            AluZero = 0;
            state = FETCH;
        end
       
        else begin
            case(state)
                FETCH: begin
                        SelMuxPC = 0;
                        SelMux2 = 0;
                        SelMux4 = 1;
                        SelMuxMem = 0;
                        PCwrite = 1;
                        MemRead = 1;
                        LoadIR = 1;
                        loadRegAluOut = 1;
                        exitState = 1;
                        AluOperation = SUM;
                        state = DECODE;
                end
 
                DECODE: begin
                        SelMuxPC = 0;
                        SelMux2 = 0;
                        SelMux4 = 3;
                    	loadRegA = 1;
                        loadRegB = 1;
                        SelMuxMem = 0;
                        PCwrite = 0;
                        MemRead = 1;
                        LoadIR = 1;
                        loadRegAluOut = 0;
                        exitState = 0;
                        AluOperation = SUM;
       
			case(INSTR[6:0])
				7'b0110011: begin   // Tipo R
                                	if (INSTR[31:25] == 7'b0000000) begin
						state = sumOP1;
                                	end
                                	if (INSTR[31:25] == 7'b0100000) begin
                                		state = subOP1;
                                	end
				end

				7'b0000011: begin   // Tipo S (load)
					state = memDRead1;
				end               

				7'b0010011: begin   // Tipo I (addi)
					state = sumsubWrite1;
                            	end

				7'b0100011: begin   // Tipo I (store)
					state = memDWrite1; //calcula o OFFSET para o LOAD, STORE, E ADDI
                            	end

				7'b1100011: begin   // Tipo SB (beq)
                                        state = beqOP1;

                            	end

				7'b1100111: begin   // Tipo SB (bne)
					state = bneOP1;

                                end

				7'b1100011: begin // lui
					state = memDRead1;
				end
			endcase
		end

			sumOP1:begin
				SelMux2 = 1;
				SelMux4 = 0;
                                exitState = 0;
                                AluOperation = SUM;
                                loadRegAluOut = 1;
				state = sumOP2;
			end

			sumOP2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 1;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = sumsubWrite1;
			end
			
			subOP1:begin
				SelMux2 = 1;
				SelMux4 = 0;
				exitState = 0;
				AluOperation = SUB;
				loadRegAluOut = 1;
				state = subOP2;
			end

			subOP2:  begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUB;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 1;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = sumsubWrite1;
			end

			beqOP1: begin
				SelMux2 = 0;
				SelMux4 = 3;
				PCwrite = 0;
                                AluOperation = SUM;
                                exitState = 0;
				loadRegAluOut = 1;
				loadRegA = 1;
				loadRegB = 1;
				SelMuxPC = 1;
				state = beqOP2;
			end

			beqOP2: begin	
					AluOperation = SUB;
                                        PCWriteCond = 1;
                                        if (AluZero == 1) begin
                                        PCwrite = 1;
                                   	end
                                        if (AluZero == 0) begin
                                            PCwrite = 0;
                                            PCWriteCond = 1'bx;
					end
					state = FETCH;
			end
	
			bneOP1: begin
				SelMux2 = 0;
				SelMux4 = 3;
				PCwrite = 0;
                                AluOperation = SUM;
                                exitState = 0;
				loadRegAluOut = 1;
				loadRegA = 1;
				loadRegB = 1;
				SelMuxPC = 1;
				state = bneOP2;
			end
                                        
			bneOP2:begin
					AluOperation = SUB;                                      
                                        if (AluZero == 0) begin
                                        	PCwrite = 1;
						PCWriteCond = 1'bx;
                                   	end
                                        if (AluZero == 1) begin
                                        	PCwrite = 0;
                                        	PCWriteCond = 0;
					end
					state = FETCH;
			end
			
			sumsubWrite1: begin
			 	AluOperation = LOAD;
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
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = sumsubWrite2;
			end

			sumsubWrite2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 0;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = FETCH;
                 	end
			
			memDRead1: begin
				 exitState = 0;
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = LOAD;
				SelMux2 = 1;
				SelMux4 = 2;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = memDRead2;
			end

			memDRead2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =0;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 1;
				MemData_Read = 1;
				MemRead = 0;
				LoadIR = 0;
				state = loadWrite;
			end

			memDWrite1: begin
				SelMux2 = 1;
				SelMux4 = 2;
                                AluOperation = LOAD;
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
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = memDWrite2;
			end

			memDWrite2: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = LOAD;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =0;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 1;
				MemRead = 0;
				LoadIR = 0;
				state = FETCH;

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
				state = FETCH;
			end
			
			/*lui: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = LOAD;
				SelMux2 = 0;
				SelMux4 = 0;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut =0;
				RegWrite = 1;
				SelMuxMem = 1;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = FETCH;
				end 
 			*/
            	endcase
	   end
        end
endmodule
