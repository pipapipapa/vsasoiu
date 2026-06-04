`timescale 1ns / 1ps

module tb_Control_Unit();
    reg clk, rst;
    reg [3:0] opcode;
    
    wire PC_Write, IR_Write, Reg_Write, Mem_Write, Mem_Read;
    wire [1:0] ALU_Src, Reg_Dst_Sel;
    wire [2:0] ALU_Op;
    wire Branch_En, Jump_En;

    Control_Unit uut (
        .clk(clk), .rst(rst), .opcode(opcode),
        .PC_Write(PC_Write), .IR_Write(IR_Write), .Reg_Write(Reg_Write),
        .Mem_Write(Mem_Write), .Mem_Read(Mem_Read), .ALU_Src(ALU_Src),
        .ALU_Op(ALU_Op), .Reg_Dst_Sel(Reg_Dst_Sel), .Branch_En(Branch_En), .Jump_En(Jump_En)
    );

    // Генерация тактов (период 10 нс)
    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        $display("control unit test");
        
        rst = 1; 
        opcode = 4'b0111; // Инструкция STORE
        
        #12;
        rst = 0; 
        
        // Сейчас автомат в состоянии FETCH (000)
        #2
        $display("FETCH: IR_Write = %b | 1", IR_Write);
        
        #10;
        
        #10;
        $display("EXECUTE (STORE): Mem_Write = %b | 1", Mem_Write);
        
        // Ждем переход в WRITEBACK
        #10;
        $display("WRITEBACK (STORE): PC_Write = %b, Reg_Write = %b | 1 0", PC_Write, Reg_Write);
        
        $display("n");
        $finish;
    end
endmodule