module stavka_b #(
    parameter NUM = 4
)(
    input rst_n,
    input clk,
    input in,
    output reg out
);

    integer timer_next, timer_reg;
    reg ff1_next, ff1_reg;
    reg ff2_next, ff2_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            ff1_reg <= 1'b0;
            ff2_reg <= 1'b0;
            timer_reg <= 0;
        end else begin
           ff1_reg <= ff1_next;
           ff2_reg <= ff2_next;
           timer_reg <= timer_next; 
        end
    end

    always @(*) begin
        ff1_next = in;
        ff2_next = ff1_reg;
        timer_next = timer_reg;
        out = 1'b0;

        if (ff1_next == 1'b1 && ff2_next == 1'b1) begin
            if (timer_reg >= 6 * NUM)
                timer_next = 0;
            else
                timer_next = timer_reg + 1;
        end
        if (ff1_next == 1'b1 && ff2_next == 1'b0) begin
            timer_next = 0;
        end
        if (ff1_next == 1'b0 && ff2_next == 1'b1) begin
            if (timer_reg >= 3 * NUM)
                out = 1'b1;
            else
                out = 1'b0;
        end
    end
    
endmodule
