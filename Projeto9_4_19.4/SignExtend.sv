module SignExtend
 
    (input logic [31:0] entrada,
     output logic [63:0] saida);
 
reg [31:0] immed;

/* initial begin
entrada = 32'b00000000001100010000001001100011;
end */

always_comb
begin
    case(entrada[6:0])
    0010011: begin //Tipo I(addi,slti,nop)
        immed[11:0] = entrada[31:20];
        saida [11:0] = immed [11:0];
        if(immed[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
    end
 
    1100111: begin //Tipo I(jalr)
        immed[11:0]=entrada[31:20];
        saida [11:0] = immed [11:0];
        if(entrada[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
    end
 
    0000011: begin //Tipo I(lb,lw,lh...)
        immed[11:0]=entrada[31:20];
        saida [11:0] = immed [11:0];
        if(immed[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
    end
 
    1110011: begin //Tipo I(break,não tem imediato)
        immed[11:0]=entrada[31:20];
        saida [11:0] = immed [11:0];
        if(immed[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
 
    end
 
    0010011: begin //Tipo I(Shifts)
        immed[11:0]=entrada[31:20];
        saida [11:0] = immed [11:0];
        if(immed[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
 
    end
 
    0100011: begin //Tipo S
        immed[4:0]=entrada[11:7];
        immed[11:5]=entrada[31:25];
        saida [11:0] = immed [11:0];
        if(immed[11])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
 
    end
 
    1100011: begin //Tipo SB(beq)
        immed[12]=entrada[31];
        immed[11]=entrada[7];
        immed[10:5]=entrada[30:25];
        immed[4:1]=entrada[11:8];
        immed[0]=0;
        saida [12:0] = immed [12:0];
        if(immed[12])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
    end
 
    1100111: begin //Tipo SB(bne,bge,blt)
        immed[12]=entrada[31];
        immed[11]=entrada[7];
        immed[10:5]=entrada[30:25];
        immed[4:1]=entrada[11:8];
        immed[0]=0;
        saida [12:0] = immed [12:0];
        if(immed[12])
            begin
            saida [31:12] = 20'hfffff;
            end
   
        else
            begin
            saida [31:12] = 20'h00000; 
            end
    end
 
    0110111: begin //Tipo U(lui)
        immed[19:0]=entrada[31:12];
        saida [19:0] = immed [19:0];
        if(immed[19])
            begin
            saida [31:20] = 12'hfff;
            end
   
        else
            begin
            saida [31:20] = 12'h000;   
            end
    end
 
    1101111: begin //Tipo UJ(jal)
        immed[20]=entrada[31];
        immed[10:1]=entrada[30:21];
        immed[11]=entrada[20];
        immed[19:12]=entrada[19:12];
        immed[0]=0;
        saida [20:0] = immed [20:0];
        if(immed[20])
            begin
            saida [31:20] = 12'hfff;
            end
   
        else
            begin
            saida [31:20] = 12'h000;   
            end
    end
 

endcase

    if(saida[31])
    begin
    saida[63:32] = 32'hffffffff;
    end
   
    else
    begin
    saida [63:32] = 32'h00000000;
    end 

end
 
endmodule: SignExtend