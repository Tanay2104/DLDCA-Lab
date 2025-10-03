module twoBitCounter(
    input wire gamma,
    input wire clk,
    input wire reset,
    output reg [1:0] count
);

    always @(posedge clk) begin
        if (reset) begin
            count<=2'b00;
        end
        else if (gamma) begin
            count <= count + 2'b01;
        end
    end
endmodule