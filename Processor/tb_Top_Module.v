`timescale 1ns / 1ps

module tb_Top_Module();

    // Сигналы для подключения к процессору
    reg clk;
    reg rst;

    // Экземпляр процессора (UUT - Unit Under Test)
    Top_Module uut (
        .clk(clk),
        .rst(rst)
    );

    // Генерация тактового сигнала (Clock) с периодом 10 нс (100 МГц)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Основной блок симуляции
    initial begin
        // Включение записи временных диаграмм (для GTKWave)
        $dumpfile("processor_wave.vcd");
        $dumpvars(0, tb_Top_Module);

        // Инициализация памяти данных (Тестовые векторы)
        uut.Data_Mem[0] = 16'd15; // Первое слагаемое
        uut.Data_Mem[1] = 16'd25; // Второе слагаемое
        uut.Data_Mem[2] = 16'd0;  // Сюда запишем результат

        // Загрузка программы в память инструкций (Машинный код)
        uut.Instr_Mem[0] = 16'h6200; // LOAD  R1, 0(R0)
        uut.Instr_Mem[1] = 16'h6401; // LOAD  R2, 1(R0)
        uut.Instr_Mem[2] = 16'h0650; // ADD   R3, R1, R2
        uut.Instr_Mem[3] = 16'h7602; // STORE R3, 2(R0)
        uut.Instr_Mem[4] = 16'h8004; // JUMP  4

        // Аппаратный сброс (Reset)
        rst = 1;
        #15;      // Ждем 1.5 такта
        rst = 0;  // Отпускаем сброс, процессор начинает работу

        // Ждем достаточное время для выполнения 5 инструкций
        // У нас 4 такта на инструкцию: 5 * 4 * 10 нс = 200 нс
        #250;

        // Вывод результатов в консоль
        $display("      results     ");
        $display("Input:");
        $display("Data_Mem[0] = %d", uut.Data_Mem[0]);
        $display("Data_Mem[1] = %d", uut.Data_Mem[1]);
        $display("----------------------------------------");
        $display("Registers after:");
        $display("R1 = %d", uut.RF.regs[1]);
        $display("R2 = %d", uut.RF.regs[2]);
        $display("R3 = %d (sum in register)", uut.RF.regs[3]);
        $display("----------------------------------------");
        $display("memory after exec store:");
        $display("Data_Mem[2] = %d (target: 40)", uut.Data_Mem[2]);
        
        if (uut.Data_Mem[2] == 16'd40)
            $display(">>> success <<<");
        else
            $display(">>> unsucces <<<");
            
        $finish;
    end

endmodule