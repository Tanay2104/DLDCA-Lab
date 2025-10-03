module tb_twoBitCounter;

  // Testbench signals
  reg clk;
  reg reset;
  reg gamma;
  wire [1:0] count;

  // Instantiate the DUT (Device Under Test)
  twoBitCounter dut (
    .clk(clk),
    .reset(reset),
    .gamma(gamma),
    .count(count)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk = 0;
    reset = 0;
    gamma = 0;

    // Apply reset
    $display("Applying reset...");
    reset = 1;
    #10;
    reset = 0;

    // Apply test cases
    $display("Starting counter test...");

    gamma = 1; #40;  // Let counter increment for 4 cycles
    gamma = 0; #20;  // Hold gamma low (count should freeze)
    gamma = 1; #40;  // Increment again

    // Reset again
    reset = 1; #10;
    reset = 0;

    gamma = 1; #30;

    // Finish simulation
    $finish;
  end

  // Monitor signals
  initial begin
    $monitor("Time=%0t | reset=%b | gamma=%b | count=%b", $time, reset, gamma, count);
  end

endmodule

module tb_fourBitAdder;

  // Testbench signals
  reg  [3:0] a, b;
  wire [3:0] S;
  wire Cout;

  // Instantiate DUT
  fourBitAdder dut2 (
    .a(a),
    .b(b),
    .S(S),
    .Cout(Cout)
  );
    wire [4:0] expected;
    assign expected = a + b;
  initial begin
    $display("Time |   a   b   |  S  Cout | Expected");
    $display("----------------------------------------");

    // Apply test cases
    a = 4'b0000; b = 4'b0000; #10;
    a = 4'b0001; b = 4'b0010; #10;
    a = 4'b0101; b = 4'b0011; #10;
    a = 4'b1111; b = 4'b0001; #10;
    a = 4'b1010; b = 4'b0110; #10;
    a = 4'b1111; b = 4'b1111; #10;

    // Finish simulation
    $finish;
  end

  // Monitor signals continuously
  initial begin
    $monitor("%4t | %4b %4b | %4b   %b   | %d",
             $time, a, b, S, Cout, expected);
  end

endmodule

module tb_X_reg;

    // Testbench signals
    reg        clk;
    reg        reset;
    reg        alpha;
    reg        beta;
    reg [3:0]  b_in;
    reg [3:0]  adder_out;
    wire[3:0]  x_out;

    // Instantiate DUT
    X_reg dut (
        .clk(clk),
        .reset(reset),
        .alpha(alpha),
        .beta(beta),
        .b_in(b_in),
        .adder_out(adder_out),
        .x_out(x_out)
    );

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Time | clk rst alp bet | b_in adder | x_out (dec)");
        $display("-------------------------------------------------");

        // Initialize inputs
        reset = 1;
        alpha = 0;
        beta  = 0;
        b_in = 4'bzzzz;       // use 'z' pattern if you want "don't care" visually
        adder_out = 4'bzzzz;

        #15;                  // wait 1.5 cycles
        reset = 0;
        $display("--> Reset released");

        #10; // one cycle
        $display("--> ALPHA load (expect x_out <= 5)");
        alpha = 1;
        b_in = 4'd5;
        adder_out = 4'd15;

        #10; // posedge will capture the load
        alpha = 0;
        b_in = 4'b0000;

        #20;
        $display("--> BETA load (expect x_out <= 10)");
        beta = 1;
        adder_out = 4'd10;
        #10;
        beta = 0;
        adder_out = 4'b0000;

        #20;
        $display("--> Priority test: alpha=1,beta=1 (alpha should win)");
        alpha = 1; beta = 1;
        b_in = 4'd3; adder_out = 4'd12;
        #10;
        alpha = 0; beta = 0;

        #20;
        $display("--> Test complete.");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("%4t |  %b   %b   %b   %b  | %2h    %2h   | %2h (%0d)",
                 $time, clk, reset, alpha, beta, b_in, adder_out, x_out, x_out);
    end

endmodule

module tb_datapath;

    // Testbench signals
    reg clk;
    reg reset;
    reg alpha;
    reg beta;
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] out;

    // Instantiate the DUT
    datapath dut (
        .clk(clk),
        .reset(reset),
        .alpha(alpha),
        .beta(beta),
        .a(a),
        .b(b),
        .out(out)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize all inputs
        clk = 0;
        reset = 1;
        alpha = 0;
        beta = 0;
        a = 4'b0;
        b = 4'b0;

        $display("Starting Datapath Testbench...");
        $display("Time | rst alp bet | a  b | out (val)");
        $display("-----------------------------------------");
        
        // Apply and release reset
        #15;
        reset = 0;
        
        // =========================================================
        // TEST CASE 1: a=2, b=3. Expected result = 4*2 + 3 = 11
        // =========================================================
        $display("\n--> TEST CASE 1: a=2, b=3. Expected=11");
        a = 4'd2;
        b = 4'd3;
        
        // Step 1: Initialize X with b (alpha = 1)
        #5; // Wait half a cycle to apply signals before clock edge
        alpha = 1;
        $display("--> Loading b into X...");
        
        #10; // After this posedge, out should be 3
        alpha = 0;

        // Step 2: Add 'a' four times (beta = 1 for 4 cycles)
        $display("--> Adding a (value 2) four times...");
        beta = 1;
        #10; // out = 3+2=5
        #10; // out = 5+2=7
        #10; // out = 7+2=9
        #10; // out = 9+2=11
        beta = 0;
        
        #10;
        $display("--> Computation complete. Final value should be 11.");

        // =========================================================
        // TEST CASE 2: a=1, b=5. Expected result = 4*1 + 5 = 9
        // =========================================================
        $display("\n--> TEST CASE 2: a=1, b=5. Expected=9");
        a = 4'd1;
        b = 4'd5;
        
        // Re-apply reset to start fresh
        reset = 1;
        #10;
        reset = 0;
        
        // Step 1: Initialize X with b (alpha = 1)
        #5; 
        alpha = 1;
        $display("--> Loading b into X...");

        #10; // After this posedge, out should be 5
        alpha = 0;

        // Step 2: Add 'a' four times (beta = 1 for 4 cycles)
        $display("--> Adding a (value 1) four times...");
        beta = 1;
        #10; // out = 5+1=6
        #10; // out = 6+1=7
        #10; // out = 7+1=8
        #10; // out = 8+1=9
        beta = 0;

        #10;
        $display("--> Computation complete. Final value should be 9.");
        
        #20;
        $finish;
    end

    // Monitor to see signal changes
    initial begin
        $monitor("%4t |  %b   %b   %b  | %d  %d | %4b (%0d)", 
                 $time, reset, alpha, beta, a, b, out, out);
    end

endmodule


// Module: tb_complete_system
// Testbench for the entire (4a + b) system.

module tb_complete_system;

    // Testbench signals
    reg clk;
    reg reset;
    reg u;
    reg [3:0] a_in;
    reg [3:0] b_in;
    wire [3:0] final_result;
    wire z_done;

    // Instantiate the DUT (Device Under Test)
    system_4a_plus_b dut (
        .clk(clk),
        .reset(reset),
        .u(u),
        .a(a_in),
        .b(b_in),
        .result(final_result),
        .z(z_done)
    );

    // Clock generation (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        u = 0;
        a_in = 4'd0;
        b_in = 4'd0;

        $display("Time | rst u | a  b | result | z_done | Description");
        $display("---------------------------------------------------------------");

        // Apply and release reset
        #15;
        reset = 0;
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | System Idle", $time, reset, u, a_in, b_in, final_result, z_done);

        // --- TEST CASE 1: a=2, b=3. Expected = 4*2 + 3 = 11 ---
        #10;
        a_in = 4'd2;
        b_in = 4'd3;
        u = 1; // Start the computation
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | Start computation (u=1)", $time, reset, u, a_in, b_in, final_result, z_done);
        
        #10;
        u = 0; // u only needs to be high for one cycle
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | u=0, computation running", $time, reset, u, a_in, b_in, final_result, z_done);

        // Wait for the done signal (z_done)
        wait (z_done == 1);
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | Computation DONE", $time, reset, u, a_in, b_in, final_result, z_done);

        // Check the result
        if (final_result == 11)
            $display("--> TEST 1 PASSED: Result is %d (expected 11)", final_result);
        else
            $display("--> TEST 1 FAILED: Result is %d (expected 11)", final_result);

        #20;

        // --- TEST CASE 2: a=3, b=5. Expected = 4*3 + 5 = 17 = 16+1 -> 0001 with carry ---
        // Since we are using 4-bit numbers, the result will be 17 mod 16 = 1.
        a_in = 4'd3;
        b_in = 4'd5;
        u = 1; // Start the computation
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | Start computation (u=1)", $time, reset, u, a_in, b_in, final_result, z_done);
        
        #10;
        u = 0; // u only needs to be high for one cycle
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | u=0, computation running", $time, reset, u, a_in, b_in, final_result, z_done);

        // Wait for the done signal (z_done)
        wait (z_done == 1);
        $display("%4t |  %b  %b | %d  %d |  %h    |   %b    | Computation DONE", $time, reset, u, a_in, b_in, final_result, z_done);
        
        if (final_result == 1)
            $display("--> TEST 2 PASSED: Result is %d (expected 1)", final_result);
        else
            $display("--> TEST 2 FAILED: Result is %d (expected 1)", final_result);
        
        #20;
        $finish;
    end
    
    // // Optional: Monitor all signals every clock cycle for debugging
    // initial begin
    //    $monitor("Time=%0t u=%b L=%b alpha=%b beta=%b gamma=%b z=%b k_count=%b result=%d", 
    //              $time, dut.controller.u, dut.controller.L, dut.alpha, dut.beta, dut.gamma, dut.z, dut.k_count, dut.result);
    // end

endmodule