module datapath(
    input wire[3:0] a,
    input wire[3:0] b,
    input clk, reset, alpha, beta,
    output wire [3:0] out
);
    wire [3:0] adder_out;
    wire cout;

    X_reg x_reg(.adder_out(adder_out), .b_in(b), 
        .alpha(alpha), .beta(beta), .reset(reset),
        .clk(clk), .x_out(out));

    fourBitAdder add(.a(a), .b(out), .S(adder_out), .Cout(cout));
endmodule
