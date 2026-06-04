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