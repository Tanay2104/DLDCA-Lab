module getNextState (
    input [2:0] currentState,
    output [2:0] nextState
);

    wire a;
    wire b;
    wire c;
    assign c = currentState[0];
    assign b = currentState[1];
    assign a = currentState[2];
    assign nextState[2] = (a & ~b) | (a & ~c) | (~a & b & c);
    assign nextState[1] = (~b & c) | (b & ~c);
    assign nextState[0] = ~c;

endmodule

module threeBitCounter (
    input clk,
    input reset,
    output reg [2:0] count
    
);
    wire[2:0] count_new;
    getNextState gt(.currentState(count), .nextState(count_new));

    always @(posedge clk) begin
        if (reset==1'b1) begin
            count<=3'b000;
        end else begin
            count <= count_new;
        end
    end
endmodule

module counterToLights (
    input [2:0] count,
    output [2:0] rgb

);
    wire a;
    wire b;
    wire c;
   assign a=count[2];
   assign b=count[1];
   assign c=count[0];
   assign rgb[2] = ~b&~c | a&~b | ~a&b&c;//correct
   assign rgb[1] = ~b&~c | ~a&~b | ~a&~c;
   assign rgb[0] = b&~c | ~a&~c | a&~b&c;
endmodule

module rgbLighter (
    input clk,
    input reset,
    output [2:0] rgb
);
    wire[2:0] count;
    threeBitCounter cnt (.clk(clk), .reset(reset), .count(count));
    counterToLights ctl (.count(count), .rgb(rgb));

endmodule
