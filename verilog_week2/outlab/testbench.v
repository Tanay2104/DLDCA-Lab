`timescale 1ns / 1ps

module tb_allModules;

    // ====== Testbench for rgbLighter (top module) ======
    reg clk;
    reg reset;
    wire [2:0] rgb;

    rgbLighter uut_rgbLighter (
        .clk(clk),
        .reset(reset),
        .rgb(rgb)
    );

    integer i;

    // Clock generation for rgbLighter and threeBitCounter
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns period

    initial begin
        $display("=== rgbLighter test ===");
        $display("Time\tclk\treset\trgb");
        $monitor("%0dns\t%b\t%b\t%03b", $time, clk, reset, rgb);

        $dumpfile("wave.vcd");
        $dumpvars(0, tb_allModules);

        reset = 1;
        #10;
        reset = 0;

        #200;
        $display("=== End rgbLighter test ===\n");
        $monitoroff; 
    end


    // ====== Testbench for getNextState ======
    reg [2:0] currentState;
    wire [2:0] nextState;

    getNextState uut_getNextState (
        .currentState(currentState),
        .nextState(nextState)
    );

    initial begin
        #220;  // Wait for rgbLighter test to finish
        $display("=== getNextState test ===");
        $display("CurrentState | NextState");
        for (i = 0; i < 8; i = i + 1) begin
            currentState = i;
            #10;
            $display("    %b     |    %b", currentState, nextState);
        end
        $display("=== End getNextState test ===\n");
    end


    // ====== Testbench for threeBitCounter ======
    reg tb_clk;
    reg tb_reset;
    wire [2:0] tb_count;

    threeBitCounter uut_threeBitCounter (
        .clk(tb_clk),
        .reset(tb_reset),
        .count(tb_count)
    );

    // Separate clock for threeBitCounter
    initial tb_clk = 0;
    always #7 tb_clk = ~tb_clk;  // 14ns period to distinguish from rgbLighter clk

    initial begin
        #500;  // Wait for previous tests
        $display("=== threeBitCounter test ===");
        tb_reset = 1;
        #14;
        tb_reset = 0;

        // Run for 10 clock cycles of tb_clk
        repeat (10) @(posedge tb_clk) 
            $display("At time %0t ns, count = %b", $time, tb_count);

        $display("=== End threeBitCounter test ===\n");
    end


    // ====== Testbench for counterToLights ======
    reg [2:0] inputCount;
    wire [2:0] rgb_out;

    counterToLights uut_counterToLights (
        .count(inputCount),
        .rgb(rgb_out)
    );

    initial begin
        #1000;  // Wait for previous tests
        $display("=== counterToLights test ===");
        $display("Count | RGB");
        for (i = 0; i < 8; i = i + 1) begin
            inputCount = i;
            #10;
            $display(" %03b  | %03b", inputCount, rgb_out);
        end
        $display("=== End counterToLights test ===\n");
        $finish;
    end

endmodule
