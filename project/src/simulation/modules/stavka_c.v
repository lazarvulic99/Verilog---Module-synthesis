module stavka_c (
    input rst_n,
    input clk,
    input select,
    input add,
    input [3:0] data_in,
    output [3:0] data_out
);

    wire add_red;
    stavka_a a0 (clk, rst_n, add, add_red);

    reg [3:0] data_next [1:0];
    reg [3:0] data_reg [1:0];
    reg [3:0] data_out_next, data_out_reg;
    assign data_out = data_out_reg;

    integer i;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 2; i = i + 1) begin
                data_reg[i] <= 4'h0;
            end
            data_out_reg <= 4'h0;
        end else begin
            for (i = 0; i < 2; i = i + 1) begin
                data_reg[i] <= data_next[i];
            end
            data_out_reg <= data_out_next;
        end
    end

    always @(*) begin
        data_out_next = data_out_reg;
        for (i = 0; i < 2; i = i + 1) begin
            data_next[i] = data_reg[i];
        end
        if (add_red == 1'b1)
            data_next[select] = (data_reg[select] + data_in) % 4'd10;
        data_out_next = data_next[select];
    end
    
endmodule
