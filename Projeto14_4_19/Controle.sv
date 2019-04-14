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
 
    //ESTADOS DA MÁQUINA DE ESTADOS
    parameter RESET = 1; 
    parameter FETCH = 2; 
    parameter DECODE = 3; 
    parameter sumOP = 4;  
    parameter subOP = 5; 
    parameter LAS = 6;
    parameter beqOP = 7; 
    parameter bneOP = 8; 
    parameter sumsubWrite = 9;
    parameter memDRead = 10;
    parameter memDWrite = 11;
    parameter loadWrite = 12;
 
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
                        SelMux4 = 1;
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
						SelMux2 = 0;
						SelMux4 = 1;
                                		exitState = 0;
                                		AluOperation = SUM;
                                		loadRegAluOut = 1;
						state = sumOP;
                                	end
                                	if (INSTR[31:25] == 7'b0100000) begin
                                		SelMux2 = 0;
						SelMux4 = 1;
						exitState = 0;
						AluOperation = SUB;
						loadRegAluOut = 1;
						state = subOP;
                                	end
				end

				7'b0000011: begin   // Tipo S (load)
                                	SelMux2 = 1;
					SelMux4 = 0;
                                        AluOperation = LOAD;
                                        exitState = 0;
					loadRegAluOut = 1;
                                        state = LAS; // Direciona a LOAD, ADDI ou STORE
				end               

				7'b0010011: begin   // Tipo I (addi)
					SelMux2 = 1;
					SelMux4 = 0;
                                        AluOperation = LOAD;
                                        exitState = 0;
					loadRegAluOut = 1;
                                        state = LAS;	
                            	end

				7'b0100011: begin   // Tipo I (store)
					SelMux2 = 1;
					SelMux4 = 0;
                                        AluOperation = LOAD;
                                        exitState = 0;
					loadRegAluOut = 1;
                                        state = LAS;	
                            	end

				7'b1100011: begin   // Tipo SB (beq)
					SelMux2 = 0;
					SelMux4 = 3;
					PCwrite = 0;
                                        AluOperation = SUM;
                                        exitState = 0;
					loadRegAluOut = 1;
					loadRegA = 1;
					loadRegB = 1;
					SelMuxPC = 1;
                                        state = beqOP;

                            	end

				7'b1100111: begin   // Tipo SB (bne)
					SelMux2 = 0;
					SelMux4 = 3;
					PCwrite = 0;
                                        AluOperation = SUM;
                                        exitState = 0;
					loadRegAluOut = 1;
					loadRegA = 1;
					loadRegB = 1;
					SelMuxPC = 1;
                                        state = bneOP;

					
                                end
			endcase
			end
			
			sumOP: begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = sumsubWrite;
			end
			

			subOP:  begin
				PCwrite = 0;
				PCWriteCond = 0;
				SelMuxPC = 0;
				AluOperation = SUM;
				SelMux2 = 0;
				SelMux4 = 1;
				loadRegA = 0;
				loadRegB = 0;
				loadRegAluOut = 1;
				RegWrite = 0;
				SelMuxMem = 0;
				loadRegMemData = 0;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = sumsubWrite;
			end

			LAS: begin
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
				case (INSTR[6:0]) //Por OPCODE
					7'b0100011: //tipo S
					begin
						state = memDWrite; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0010011: //tipo I (ADDI)
					begin
						state = sumsubWrite; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0000011: //tipo I (LD)
					begin
						state = memDRead; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					endcase
				end 

			beqOP: begin	
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

			bneOP:begin
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

			sumsubWrite: begin
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
			
			memDRead: begin
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
				loadRegMemData = 1;
				MemData_Read = 0;
				MemRead = 0;
				LoadIR = 0;
				state = loadWrite;
			end

			memDWrite: begin
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
				 end */

                        /*    7'b1100011: begin   // Tipo SB (BEQ)
                            stateBeq = BEQ_INIT;
                                case(stateBeq)
                                    BEQ_INIT: begin
                                        SelMux2 = 0;
                                        SelMux4 = 3;
                                        MemRead = 0;
                                    	loadRegAluOut = 1;
                                        loadRegA = 1;
                                        loadRegB = 1;
                                        LoadIR = 0;
                                        exitState = 0;
                                    	SelMuxPC = 1;
                                        stateBeq = BEQ_COMP;
                                    end
                 
                                    BEQ_COMP: begin
                                        AluOperation = SUB;
                                        PCWriteCond = 1;
                                        SelMuxPC = 1;
                                        if (AluZero == 1) begin
                                        PCwrite = 1;
                                    end
                                        if (AluZero == 0) begin
                                            PCwrite = 0;
                                            PCWriteCond = 1'bx;
                                    end
                                    end
                                endcase
                                state = FETCH;
                            end
   
                            7'b1100111: begin   // Tipo SB (BNE)
                                exitState = 0;
                                SelMux2 = 1;
                                SelMux4 = 0;
                                MemRead = 0;
                                LoadIR = 0;
                                AluOperation = SUB;
                                SelMuxPC = 1;
                                PCWriteCond = 0;
                                if (AluZero) begin
                                    PCwrite = 0;
                                end
                                state = FETCH;
                            end
 		*/
             
            /*              7'b0110111: begin   // Tipo U (LUI)
                                PCwrite = 0;
                                MemRead = 0;
                                LoadIR = 1;
                                SelMux2 = 1;
                                SelMux4 = 2;
                                loadRegA = 1;
                                loadRegB = 0;
                                loadRegAluOut = 1;
                                exitState = 10;
                                AluOperation = SUB;
                                    nextState = BEQ_DATA;
                            end
       
                            BEQ_DATA: begin
                                MemData_Read = 1;
                                RegWrite = 0;
                                    loadRegMemData = 1;
                                nextState = BEQ_DATA_COMP;
                            end */
		/*LOAD_DATA: begin
                                        AluOperation = SUM;
                                        MemData_Read = 1;
                                            loadRegMemData = 1;
                                        stateLoad = LOAD_DATA_COMP;
                                    end
               
                                    LOAD_DATA_COMP: begin
                                        loadRegMemData = 1;
                                        SelMuxMem = 1;
                                        RegWrite = 1;
                                        $stop;
                                    end
   		case (stateAddi)
                                    ADDI_INIT: begin
                                        PCwrite = 0;
                                        MemRead = 0;
                                        LoadIR = 0;
                                        SelMux2 = 1;
                                        SelMux4 = 2;
                                        loadRegA = 1;
                                        loadRegB = 0;
                                        loadRegAluOut = 1;
                                        exitState = 0;
                                        AluOperation = SUM ;
                                            stateAddi = ADDI_COMP;
                                    end
   
                                    ADDI_COMP: begin
                                        SelMuxMem = 0;
                                        RegWrite = 1;
                                    end
                                endcase
                                state = FETCH;
		*/
           
            	endcase
	   end
        end
endmodule
