module stavka_e #(
    parameter NUM = 50_000_000
)(
    input rst_n,
    input clk,
    input select,
    input add,
    input next,
    input [3:0] data_in,
    output [3:0] data_out
);

    wire add_red;
    stavka_a a0 (clk, rst_n, add, add_red);

    wire next_red;
    stavka_a a1 (clk, rst_n, next, next_red);

    reg [3:0] data_next [1:0];
    reg [3:0] data_reg [1:0];
    reg [3:0] data_out_next, data_out_reg;
    reg [3:0] gcd_next, gcd_reg;
    reg [3:0] result_next [1:0], result_reg[1:0];
    reg [1:0] state_next, state_reg;
    assign data_out = data_out_reg;
    integer timer_next, timer_reg;

    localparam setup = 2'b00;
    localparam gcd = 2'b01;
    localparam timer = 2'b10;

    integer i;
    reg [3:0] j;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 2; i = i + 1) begin
                data_reg[i] <= 4'h0;
                result_reg[i] <= 4'h0;
            end
            data_out_reg <= 4'h0;
            gcd_reg <= 4'h0;
            state_reg <= setup;
            timer_reg <= 0;
        end
        else begin
            for (i = 0; i < 2; i = i + 1) begin
                data_reg[i] <= data_next[i];
                result_reg[i] <= result_next[i];
            end
            data_out_reg <= data_out_next;
            gcd_reg <= gcd_next;
            state_reg <= state_next;
            timer_reg <= timer_next;
        end
    end

    always @(*) begin
        data_out_next = data_out_reg;
        state_next = state_reg;
        gcd_next = gcd_reg;
        timer_next = timer_reg;
        for (i = 0; i < 2; i = i + 1) begin
            data_next[i] = data_reg[i];
            result_next[i] = result_reg[i];
        end
        j = 4'd0;

        case (state_reg)
            setup: begin
                if (next_red) begin
                    state_next = gcd;
                end
                if (add_red == 1'b1)
                    data_next[select] = (data_reg[select] + data_in) % 4'd10;
                data_out_next = data_next[select];
            end
            gcd: begin
                if (next_red) begin
                    state_next = timer;
                end
                for (j = 4'd1; j < 4'd10; j = j + 4'd1) begin
                    if ((data_reg[0] % j == 4'd0) && (data_reg[1] % j == 4'd0))
                        gcd_next = j;
                end
                for (i = 0; i < 2; i = i + 1) begin
                    result_next[i] = data_reg[i] / gcd_next;
                end
                data_out_next = result_next[select];
            end
            timer: begin
                if (timer_next == NUM) begin
                    timer_next = 0;
                    gcd_next = gcd_reg - 1'd1;
                end else begin
                    timer_next = timer_reg + 1;
                end
                data_out_next = gcd_next;
                if (gcd_reg == 4'h0 || (next_red == 1'b1 && (data_reg[0] % gcd_reg == 4'd0) && (data_reg[1] % gcd_reg == 4'd0))) begin
                    state_next = setup;
                    data_out_next = data_next[select];
                end
            end
        endcase
    end
    
endmodule
