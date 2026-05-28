module ALU (
    input  [15:0] A,
    input  [15:0] B,
    input  [2:0]  ALU_Op,
    output reg [15:0] Result,
    output Zero
);
    always @(*) begin
        case (ALU_Op)
            3'b000: Result = A + B;       // ADD
            3'b001: Result = A - B;       // SUB
            3'b010: Result = A & B;       // AND
            3'b011: Result = A | B;       // OR
            3'b100: Result = A ^ B;       // XOR
            3'b101: Result = ~A;          // NOT
            default: Result = 16'd0;
        endcase
    end
    
    // Флаг нуля для ветвлений (BEQ)
    assign Zero = (Result == 16'd0) ? 1'b1 : 1'b0;
endmodule

module Register_File (
    input  clk,
    input  we,
    input  [2:0] read_reg1,
    input  [2:0] read_reg2,
    input  [2:0] write_reg,
    input  [15:0] write_data,
    output [15:0] read_data1,
    output [15:0] read_data2
);
    reg [15:0] regs [0:7];
    integer i;

    // Инициализация нулями
    initial begin
        for (i = 0; i < 8; i = i + 1) regs[i] = 16'd0;
    end

    // R0 всегда равен 0
    assign read_data1 = (read_reg1 == 3'b000) ? 16'd0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 3'b000) ? 16'd0 : regs[read_reg2];

    always @(posedge clk) begin
        if (we && write_reg != 3'b000) begin
            regs[write_reg] <= write_data;
        end
    end
endmodule

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

    // Кодирование состояний автомата
    localparam FETCH      = 3'b000;
    localparam DECODE     = 3'b001;
    localparam EXECUTE    = 3'b010;
    localparam WRITEBACK  = 3'b011;

    reg [2:0] current_state, next_state;

    // 1. регистр сотсояний
    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= FETCH;
        else     current_state <= next_state;
    end

    // 2. комбинационная логика переходов
    always @(*) begin
        case (current_state)
            FETCH:      next_state = DECODE;
            DECODE:     next_state = EXECUTE;
            EXECUTE:    next_state = WRITEBACK;
            WRITEBACK:  next_state = FETCH;
            default:    next_state = FETCH;
        endcase
    end

    // 3. комбинационая логика выходов
    always @(*) begin
        // Значения по умолчанию
        PC_Write = 0; IR_Write = 0; Reg_Write = 0; Mem_Write = 0; Mem_Read = 0;
        Branch_En = 0; Jump_En = 0; Reg_Dst_Sel = 2'b00;

        // ИСПРАВЛЕНИЕ: Сигналы для АЛУ зависят только от инструкции. 
        // Это гарантирует стабильный адрес памяти во время такта WRITEBACK!
        ALU_Src = 2'b00;
        ALU_Op  = 3'b000;
        case (opcode)
            4'b0000: ALU_Op = 3'b000; // ADD
            4'b0001: ALU_Op = 3'b001; // SUB
            4'b0010: ALU_Op = 3'b010; // AND
            4'b0011: ALU_Op = 3'b011; // OR
            4'b0100: ALU_Op = 3'b100; // XOR
            4'b0101: ALU_Op = 3'b101; // NOT
            4'b0110: begin ALU_Src = 2'b01; ALU_Op = 3'b000; end // LOAD
            4'b0111: begin ALU_Src = 2'b01; ALU_Op = 3'b000; end // STORE
            4'b1001: begin ALU_Op = 3'b001; end // BEQ
        endcase

        // Сигналы, зависящие от текущего такта (FSM State)
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
                    4'b1001: Branch_En = 1; // BEQ
                    4'b1000: Jump_En = 1;   // JUMP
                endcase
            end
            
            WRITEBACK: begin
                PC_Write = 1; // Обновляем программный счетчик
                case (opcode)
                    4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: begin 
                        Reg_Write = 1; Reg_Dst_Sel = 2'b00; // Запись результата АЛУ
                    end
                    4'b0110: begin 
                        Reg_Write = 1; Reg_Dst_Sel = 2'b01; // Запись данных из памяти
                    end
                endcase
            end
        endcase
    end
endmodule

module Top_Module (
    input clk,
    input rst
);
    // Программный счетчик (PC) и регистр инструкций (IR)
    reg [11:0] PC;
    reg [15:0] IR;

    // Память
    reg [15:0] Instr_Mem [0:1023];
    reg [15:0] Data_Mem  [0:1023];

    // Внутренние провода
    wire [15:0] instr_wire = Instr_Mem[PC];
    
    wire PC_Write, IR_Write, Reg_Write, Mem_Write, Mem_Read, Branch_En, Jump_En;
    wire [1:0] ALU_Src, Reg_Dst_Sel;
    wire [2:0] ALU_Op;
    
    wire [15:0] rd1, rd2, alu_res;
    wire alu_zero;
    
    // Распаковка инструкции (IR)
    wire [3:0]  opcode = IR[15:12];
    wire [2:0]  reg_dst = IR[11:9];
    wire [2:0]  reg_src1 = IR[8:6];
    wire [2:0]  reg_src2 = (opcode == 4'b0111) ? reg_dst : IR[5:3];
    wire [5:0]  imm6 = IR[5:0];
    wire [11:0] imm12 = IR[11:0];
    
    // Расширение знака для immediate
    wire [15:0] sign_ext_imm = {{10{imm6[5]}}, imm6};

    // Обновление IR
    always @(posedge clk) begin
        if (IR_Write) IR <= instr_wire;
    end

    Control_Unit CU (
        .clk(clk), .rst(rst), .opcode(opcode),
        .PC_Write(PC_Write), .IR_Write(IR_Write), .Reg_Write(Reg_Write),
        .Mem_Write(Mem_Write), .Mem_Read(Mem_Read), .ALU_Src(ALU_Src),
        .ALU_Op(ALU_Op), .Reg_Dst_Sel(Reg_Dst_Sel), .Branch_En(Branch_En), .Jump_En(Jump_En)
    );

    // Мультиплексор данных для записи в регистр
    wire [15:0] write_data_to_reg = (Reg_Dst_Sel == 2'b01) ? Data_Mem[alu_res[11:0]] : alu_res;

    Register_File RF (
        .clk(clk), .we(Reg_Write),
        .read_reg1(reg_src1), .read_reg2(reg_src2), .write_reg(reg_dst),
        .write_data(write_data_to_reg),
        .read_data1(rd1), .read_data2(rd2)
    );

    // Мультиплексор второго операнда АЛУ
    wire [15:0] alu_b_in = (ALU_Src == 2'b01) ? sign_ext_imm : rd2;

    ALU ALU_Inst (
        .A(rd1), .B(alu_b_in), .ALU_Op(ALU_Op),
        .Result(alu_res), .Zero(alu_zero)
    );

    // Работа с памятью данных
    always @(posedge clk) begin
        if (Mem_Write) Data_Mem[alu_res[11:0]] <= rd2; // Для store rd2 - это данные (поле Rd в инструкции)
    end

    // Логика следующего адреса (PC)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 12'd0;
        end else if (PC_Write) begin
            if (Jump_En) 
                PC <= imm12;
            else if (Branch_En && alu_zero) 
                PC <= PC + 1 + sign_ext_imm[11:0];
            else 
                PC <= PC + 1;
        end
    end
endmodule