module X_reg(
    input wire[3:0] adder_out,
    input wire[3:0] b_in,
    input wire clk,
    input wire alpha,
    input wire beta,
    input wire reset,
    output reg[3:0] x_out
);
    always @(posedge clk) begin
        if (reset) begin
            x_out<=4'b0000;
        end
        else if (alpha) begin
            x_out <= b_in;
        end
        else if (beta) begin
            x_out <= adder_out;
        end
    end
endmodule