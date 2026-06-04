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