module Control_Unit (
    input  clk,
    input  rst,
    input  [3:0] opcode,
    
    output reg PC_Write,
    output reg IR_Write,
    output reg Reg_Write,
    output reg Mem_Write,
    output reg Mem_Read,
    output reg [1:0] ALU_Src,
    output reg [2:0] ALU_Op,
    output reg [1:0] Reg_Dst_Sel,
    output reg Branch_En,
    output reg Jump_En
);

    localparam FETCH      = 3'b000;
    localparam DECODE     = 3'b001;
    localparam EXECUTE    = 3'b010;
    localparam WRITEBACK  = 3'b011;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= FETCH;
        else     current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            FETCH:      next_state = DECODE;
            DECODE:     next_state = EXECUTE;
            EXECUTE:    next_state = WRITEBACK;
            WRITEBACK:  next_state = FETCH;
            default:    next_state = FETCH;
        endcase
    end

    // комбинационная логика выходов
    always @(*) begin
        // Значения по умолчанию
        PC_Write = 0; IR_Write = 0; Reg_Write = 0; Mem_Write = 0; Mem_Read = 0; Reg_Dst_Sel = 2'b00;

        // Глобальные сигналы
        ALU_Src = 2'b00;
        ALU_Op  = 3'b000;
        Branch_En = 0;
        Jump_En = 0;
        
        case (opcode)
            4'b0000: ALU_Op = 3'b000; // ADD
            4'b0001: ALU_Op = 3'b001; // SUB
            4'b0010: ALU_Op = 3'b010; // AND
            4'b0011: ALU_Op = 3'b011; // OR
            4'b0100: ALU_Op = 3'b100; // XOR
            4'b0101: ALU_Op = 3'b101; // NOT
            4'b0110: begin ALU_Src = 2'b01; ALU_Op = 3'b000; end // LOAD
            4'b0111: begin ALU_Src = 2'b01; ALU_Op = 3'b000; end // STORE
            4'b1001: begin ALU_Op = 3'b001; Branch_En = 1; end // BEQ
            4'b1000: begin Jump_En = 1; end // JUMP
        endcase

        // Сигналы, зависящие от текущего такта
        case (current_state)
            FETCH: begin
                IR_Write = 1;
            end
            DECODE: begin
                // Ожидание чтения из регистрового файла
            end
            EXECUTE: begin
                case (opcode)
                    4'b0110: Mem_Read = 1;  // LOAD
                    4'b0111: Mem_Write = 1; // STORE
                endcase
            end
            WRITEBACK: begin
                PC_Write = 1; // Обновляем PC в конце цикла
                case (opcode)
                    4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: begin 
                        Reg_Write = 1; Reg_Dst_Sel = 2'b00; 
                    end
                    4'b0110: begin 
                        Reg_Write = 1; Reg_Dst_Sel = 2'b01; 
                    end
                endcase
            end
        endcase
    end
endmodule