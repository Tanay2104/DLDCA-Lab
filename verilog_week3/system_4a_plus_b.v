// Module: system_4a_plus_b
// This is the top-level module that connects the controller, datapath, and counter.

module system_4a_plus_b(
    input wire clk,
    input wire reset,
    input wire u,             // Overall start signal
    input wire [3:0] a,       // 4-bit input a
    input wire [3:0] b,       // 4-bit input b
    output wire [3:0] result, // The final result from the datapath
    output wire z             // Done signal from the controller
);

    // Internal wires to connect the components
    wire alpha;
    wire beta;
    wire gamma;
    wire L;
    wire [1:0] k_count; // Output from the counter

    // Instantiate the Controller (our "brain")
    sequential_circuit_M_behavioral controller (
        .clk(clk),
        .reset(reset),
        .u(u),
        .L(L),
        .alpha(alpha),
        .beta(beta),
        .gamma(gamma),
        .z(z)
    );

    // Instantiate the Datapath (our "calculator")
    datapath datapath_unit (
        .clk(clk),
        .reset(reset),
        .alpha(alpha),
        .beta(beta),
        .a(a),
        .b(b),
        .out(result)
    );

    // Instantiate the 2-bit Counter
    twoBitCounter counter (
        .clk(clk),
        .reset(reset),      // Reset the counter with the main system reset
        .gamma(gamma),
        .count(k_count)
    );

    // Logic to generate the 'L' signal.
    // L is high when the counter reaches its max value for 4 additions.
    // The additions happen for counts 0, 1, 2, 3.
    // So, L should be 1 when count is 3 (binary 11).
    assign L = (k_count == 2'b11);

endmodule