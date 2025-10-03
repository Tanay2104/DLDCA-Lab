// Module: sequential_circuit_M
// Implements the controller based on the provided state diagram and logic equations.

module sequential_circuit_M(
    input wire clk,
    input wire reset,
    input wire u,         // Initiate signal
    input wire L,         // Counter is done signal (K=4)
    output wire alpha,    // Control signal: Load b into X
    output wire beta,     // Control signal: Load X+a into X
    output wire gamma,    // Control signal: Increment counter K
    output wire z         // Output signal: Computation is done
);

    // State registers (y1, y2) for the two D-flip-flops
    reg y1, y2;

    // Next-state logic wires (Y1, Y2)
    wire Y1, Y2;

    // State Assignment (from slide):
    // A: y1y2 = 00 (Idle)
    // B: y1y2 = 01 (Load b)
    // C: y1y2 = 11 (Add a)
    // D: y1y2 = 10 (Done)

    // ========== 1. State Transition Logic (Sequential) ==========
    // This is the clocked part that updates the current state to the next state.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, go to the initial state A (00)
            y1 <= 1'b0;
            y2 <= 1'b0;
        end else begin
            // On each clock edge, update the state
            y1 <= Y1;
            y2 <= Y2;
        end
    end

    // ========== 2. Next-State Logic (Combinational) ==========
    // These are the equations for Y1 and Y2 from the K-maps on the slide.
    // Y1 = y2
    assign Y1 = y2;

    // Y2 = y1'y2 + uy1' + L'y2
    // Verilog translation:
    assign Y2 = (~y1 & y2) | (u & ~y1) | (~L & y2);


    // ========== 3. Output Logic (Combinational) ==========
    // These equations determine the outputs based on the *current* state (y1, y2).
    // alpha = y1'y2  (True only in state B=01)
    assign alpha = ~y1 & y2;

    // beta = y1y2   (True only in state C=11)
    assign beta = y1 & y2;

    // gamma = y1y2  (True only in state C=11)
    assign gamma = y1 & y2;

    // z = y1y2'    (True only in state D=10)
    assign z = y1 & ~y2;

endmodule


// Module: sequential_circuit_M_behavioral
// Implements the same controller using the modern, behavioral FSM template.

module sequential_circuit_M_behavioral(
    input wire clk,
    input wire reset,
    input wire u,         // Initiate signal
    input wire L,         // Counter is done signal
    output reg alpha,     // Control signal: Load b into X
    output reg beta,      // Control signal: Load X+a into X
    output reg gamma,     // Control signal: Increment counter K
    output reg z          // Output signal: Computation is done
);

    // 1. State Declarations (like the yellow box)
    // Use parameters for readable state names
    parameter STATE_A_IDLE = 2'b00;
    parameter STATE_B_LOAD = 2'b01;
    parameter STATE_C_ADD  = 2'b11;
    parameter STATE_D_DONE = 2'b10;

    // State registers
    reg [1:0] state, nxt_state;

    // 2. State Transition Logic (like the pink box)
    // This is the sequential block that updates the state register.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_A_IDLE;
        end else begin
            state <= nxt_state;
        end
    end

    // 3. Next-State and Output Logic (like the blue box)
    // This is the combinational block that determines the next state and outputs.
    always @(*) begin
        // First, set default values for all outputs
        alpha = 1'b0;
        beta  = 1'b0;
        gamma = 1'b0;
        z     = 1'b0;
        nxt_state = state; // Default to staying in the current state

        // Now, describe the logic for each state
        case (state)
            STATE_A_IDLE: begin
                if (u == 1) begin
                    nxt_state = STATE_B_LOAD;
                end else begin
                    nxt_state = STATE_A_IDLE;
                end
            end

            STATE_B_LOAD: begin
                // In this state, load b into X
                alpha = 1'b1;
                // Unconditionally move to the next state
                nxt_state = STATE_C_ADD;
            end

            STATE_C_ADD: begin
                // In this state, add 'a' to X and increment the counter
                beta = 1'b1;
                gamma = 1'b1;
                // Check if we are done adding
                if (L == 1) begin
                    nxt_state = STATE_D_DONE;
                end else begin
                    nxt_state = STATE_C_ADD;
                end
            end

            STATE_D_DONE: begin
                // In this state, signal that the result is ready
                z = 1'b1;
                // Wait for 'u' to go low before returning to idle
                if (u == 0) begin
                    nxt_state = STATE_A_IDLE;
                end else begin
                    nxt_state = STATE_D_DONE;
                end
            end

            default: begin
                // For any undefined states, go back to a safe state
                nxt_state = STATE_A_IDLE;
            end
        endcase
    end

endmodule