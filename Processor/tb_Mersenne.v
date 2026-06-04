`timescale 1ns / 1ps

module tb_Mersenne();
    reg clk;
    reg rst;

    Top_Module uut (
        .clk(clk),
        .rst(rst)
    );

    wire [15:0] debug_R1 = uut.RF.regs[1];
    wire [15:0] debug_R3 = uut.RF.regs[3];
    wire [15:0] debug_Mem1 = uut.Data_Mem[1];

    // Генератор тактов
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("mersenne_wave.vcd");
        $dumpvars(0, tb_Mersenne);

        uut.Data_Mem[0] = 16'd3; // n = 3
        uut.Data_Mem[1] = 16'd0; // Выход
        uut.Data_Mem[2] = 16'd1; // 1


        uut.Instr_Mem[0] = 16'h6200; // 0: LOAD R1, 0(R0)
        uut.Instr_Mem[1] = 16'h6802; // 1: LOAD R4, 2(R0)
        uut.Instr_Mem[2] = 16'h6602; // 2: LOAD R3, 2(R0)
        uut.Instr_Mem[3] = 16'h9203; // 3: BEQ R1, R0, 3
        uut.Instr_Mem[4] = 16'h06D8; // 4: ADD R3, R3, R3
        uut.Instr_Mem[5] = 16'h1260; // 5: SUB R1, R1, R4
        uut.Instr_Mem[6] = 16'h8003; // 6: JUMP 3
        uut.Instr_Mem[7] = 16'h16E0; // 7: SUB R3, R3, R4
        uut.Instr_Mem[8] = 16'h7601; // 8: STORE R3, 1(R0)
        uut.Instr_Mem[9] = 16'h8009; // 9: JUMP 9

        // Запуск процессора
        rst = 1;
        #15;      
        rst = 0;  

        #800;

        $display("n = %d", uut.Data_Mem[0]);
        $display("--------------------------------------------------");
        $display("Result:");
        $display("Data_Mem[1] = %d", uut.Data_Mem[1]);
        
        if (uut.Data_Mem[1] == 16'd255)
            $display("\nsuccess");
        else
            $display("\nunsuccess");
            
        $finish;
    end
endmodule