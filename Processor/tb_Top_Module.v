`timescale 1ns / 1ps

module tb_Top_Module();
    reg clk;
    reg rst;

    Top_Module uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("processor_wave.vcd");
        $dumpvars(0, tb_Top_Module);

        // Входные данные
        uut.Data_Mem[0] = 16'd15; // 0000 1111 (Bin)
        uut.Data_Mem[1] = 16'd25; // 0001 1001 (Bin)
        uut.Data_Mem[2] = 16'd0;  
        uut.Data_Mem[3] = 16'd0;  
        uut.Data_Mem[4] = 16'd0; // ошибка, если BEQ не сработает

        uut.Instr_Mem[0]  = 16'h6200; // 0: LOAD R1, 0(R0)   
        uut.Instr_Mem[1]  = 16'h6401; // 1: LOAD R2, 1(R0)   
        uut.Instr_Mem[2]  = 16'h0650; // 2: ADD R3, R1, R2   
        uut.Instr_Mem[3]  = 16'h1888; // 3: SUB R4, R2, R1   
        uut.Instr_Mem[4]  = 16'h2A50; // 4: AND R5, R1, R2   
        uut.Instr_Mem[5]  = 16'h3C50; // 5: OR  R6, R1, R2 
        uut.Instr_Mem[6]  = 16'h4E50; // 6: XOR R7, R1, R2 
        uut.Instr_Mem[7]  = 16'h5240; // 7: NOT R1, R1       
        uut.Instr_Mem[8]  = 16'h9001; // 8: BEQ R0, R0, +1   
        uut.Instr_Mem[9]  = 16'h800D; // 9: JUMP 13          
        uut.Instr_Mem[10] = 16'h7602; // 10: STORE R3, 2(R0) 
        uut.Instr_Mem[11] = 16'h7803; // 11: STORE R4, 3(R0) 
        uut.Instr_Mem[12] = 16'h800C; // 12: JUMP 12         
        uut.Instr_Mem[13] = 16'h7A04; // 13: STORE R5, 4(R0)

        // Запуск
        rst = 1;
        #15;      
        rst = 0;  

        #800;

        $display("R3 (ADD) = %d  | 40", uut.RF.regs[3]);
        $display("R4 (SUB) = %d  | 10", uut.RF.regs[4]);
        $display("R5 (AND) = %d  | 9", uut.RF.regs[5]);
        $display("R6 (OR)  = %d  | 31", uut.RF.regs[6]);
        $display("R7 (XOR) = %d  | 22", uut.RF.regs[7]);
        $display("R1 (NOT) = %d  | 65520", uut.RF.regs[1]);
        $display("----------------------------------------");
        $display("BEQ test:");
        
        if (uut.Data_Mem[4] == 16'd9)
            $display("unsuccess beq");
        else if (uut.Data_Mem[2] == 16'd40 && uut.Data_Mem[3] == 16'd10)
            $display("succcess");
        else
            $display("unsuccess mem");
            
        $finish;
    end
endmodule