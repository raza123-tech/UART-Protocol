module receiver #(
    parameter integer CLK_FREQ   = 1000000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer DIV_SAMPLE = 4
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rxd,
    output wire [7:0] rxddata,
    output reg        data_ready
);
    localparam integer DIV_COUNTER = CLK_FREQ / (BAUD_RATE * DIV_SAMPLE);
    localparam integer MID_SAMPLE  = DIV_SAMPLE / 2;
    localparam integer DIV_BIT     = 10;

    reg [13:0] baudcnt;
    reg [1:0] samplecnt;
    reg [3:0] bitcnt;
    reg [9:0] rxshift;
    reg state;

    assign rxddata = rxshift[8:1];

    initial begin
        baudcnt = 0;
        samplecnt = 0;
        bitcnt = 0;
        rxshift = 10'h3FF;
        data_ready = 1'b0;
        state = 1'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 1'b0;
            baudcnt <= 0;
            samplecnt <= 0;
            bitcnt <= 0;
            rxshift <= 10'h3FF;
            data_ready <= 1'b0;
        end else begin
            data_ready <= 1'b0;
            if (baudcnt < DIV_COUNTER - 1) begin
                baudcnt <= baudcnt + 1;
            end else begin
                baudcnt <= 0;
                if (state == 1'b0) begin
                    samplecnt <= 0;
                    bitcnt <= 0;
                    if (~rxd) begin
                        state <= 1'b1;
                    end
                end else begin
                    if (samplecnt == MID_SAMPLE - 1) begin
                        rxshift <= {rxd, rxshift[9:1]};
                    end

                    if (samplecnt < DIV_SAMPLE - 1) begin
                        samplecnt <= samplecnt + 1;
                    end else begin
                        samplecnt <= 0;
                        bitcnt <= bitcnt + 1;
                        if (bitcnt + 1 >= DIV_BIT) begin
                            data_ready <= 1'b1;
                            state <= 1'b0;
                        end
                    end
                end
            end
        end
    end
endmodule

