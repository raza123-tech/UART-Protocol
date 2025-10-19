module transmitter #(
    parameter integer CLK_FREQ  = 1000000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  data_in,
    input  wire        transmit,
    output reg         txd,
    output reg         tx_done
);

    localparam integer BAUD_COUNT = CLK_FREQ / BAUD_RATE;
    reg state;
    reg [15:0] baudcnt;
    reg [3:0] bits_sent;
    reg [9:0] shift_reg;

    initial begin
        state = 0;
        baudcnt = 0;
        bits_sent = 0;
        shift_reg = 10'h3FF;
        txd = 1'b1;
        tx_done = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            baudcnt <= 0;
            bits_sent <= 0;
            shift_reg <= 10'h3FF;
            txd <= 1'b1;
            tx_done <= 1'b0;
        end else begin
            tx_done <= 1'b0;
            if (state == 1'b0) begin
                if (transmit) begin
                    baudcnt <= 0;
                    bits_sent <= 0;
                    shift_reg <= {1'b1, data_in, 1'b0};
                    state <= 1'b1;
                end
            end else begin
                if (baudcnt < BAUD_COUNT - 1)
                    baudcnt <= baudcnt + 1;
                else begin
                    baudcnt <= 0;
                    txd <= shift_reg[0];
                    shift_reg <= {1'b1, shift_reg[9:1]};
                    bits_sent <= bits_sent + 1;
                    if (bits_sent + 1 >= 10) begin
                        tx_done <= 1'b1;
                        state <= 1'b0;
                        txd <= 1'b1;
                    end
                end
            end
        end
    end
endmodule

