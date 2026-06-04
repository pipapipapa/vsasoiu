`timescale 1ns / 1ps

module tb_Register_File();
    reg clk, we;
    reg [2:0] read_reg1, read_reg2, write_reg;
    reg [15:0] write_data;
    wire [15:0] read_data1, read_data2;

    // Подключаем изолированный Регистровый файл
    Register_File uut (
        .clk(clk), .we(we),
        .read_reg1(read_reg1), .read_reg2(read_reg2), .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        $display("reg file test");
        
        // 1. Попытка записать в R0 (должно игнорироваться)
        we = 1; write_reg = 3'd0; write_data = 16'hFFFF; #10;
        
        // 2. Запись в R1 и R2
        we = 1; write_reg = 3'd1; write_data = 16'hAAAA; #10;
        we = 1; write_reg = 3'd2; write_data = 16'hBBBB; #10;
        
        // 3. Чтение и проверка
        we = 0; 
        read_reg1 = 3'd0; read_reg2 = 3'd1; #10;
        $display("read R0: %h | 0000", read_data1);
        $display("read R1: %h | aaaa", read_data2);
        
        read_reg1 = 3'd2; #10;
        $display("read R2: %h | bbbb", read_data1);
        
        $display("\n");
        $finish;
    end
endmodule