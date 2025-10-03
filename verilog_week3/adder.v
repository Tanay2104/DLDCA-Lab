module fourBitAdder(
    input wire[3:0] a,
    input wire[3:0] b,
    output wire[3:0] S,
    output wire Cout
);
    wire [2:0] C;
    fullAdder f1(.a(a[0]), .b(b[0]), .c(1'b0), .S(S[0]), .C(C[0]));
    fullAdder f2(.a(a[1]), .b(b[1]), .c(C[0]), .S(S[1]), .C(C[1]));
    fullAdder f3(.a(a[2]), .b(b[2]), .c(C[1]), .S(S[2]), .C(C[2]));
    fullAdder f4(.a(a[3]), .b(b[3]), .c(C[2]), .S(S[3]), .C(Cout));

endmodule

module fullAdder(
    input wire a, b, c,
    output wire S, C
);
    assign S = a ^ b ^ c;
    assign C = a&b | b&c | c&a;

endmodule