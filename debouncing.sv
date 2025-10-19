module debouncing #(
    parameter integer THRESHOLD = 100
)(
    input  wire clk,
    input  wire btn,
    output reg  transmit
);
    reg ff1, ff2;
    reg [31:0] count;

    initial begin
        ff1 = 1'b0;
        ff2 = 1'b0;
        count = 0;
        transmit = 1'b0;
    end

    always @(posedge clk) begin
        ff1 <= btn;
        ff2 <= ff1;
    end

    always @(posedge clk) begin
        if (ff2) begin
            if (count < THRESHOLD) count <= count + 1;
        end else begin
            if (count > 0) count <= count - 1;
        end

        if (count >= THRESHOLD) transmit <= 1'b1;
        else transmit <= 1'b0;
    end
endmodule