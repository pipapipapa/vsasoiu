`timescale 1ns / 1ps

module tb_ALU();
    reg [15:0] A;
    reg [15:0] B;
    reg [2:0] ALU_Op;
    wire [15:0] Result;
    wire Zero;

    ALU uut (
        .A(A), .B(B), .ALU_Op(ALU_Op),
        .Result(Result), .Zero(Zero)
    );

    initial begin
        $display("ALU test");
        
        A = 16'd15; B = 16'd25; // Задаем тестовые числа
        
        ALU_Op = 3'b000; #10; // ADD
        $display("ADD: 15 + 25 = %d | 40", Result);
        
        ALU_Op = 3'b001; #10; // SUB
        $display("SUB: 15 - 25 = %d | 65526 / -10", Result);
        
        // Проверка флага Zero
        A = 16'd10; B = 16'd10;
        ALU_Op = 3'b001; #10; // SUB (10 - 10 = 0)
        $display("ZERO FLAG (10 - 10): Result = %d, Zero = %b | 0 1", Result, Zero);

        $display("\n");
        $finish;
    end
endmodule