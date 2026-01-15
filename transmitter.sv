module transmitter #(
    parameter clk_freq = 50000000,
    parameter baud_rate = 9600
)(
    input clk,
    input reset,
    input [7:0] data,
    input transmit,
    output reg txd,
    
);
    localparam div_val = clk_freq / baud_rate;

    reg [3:0] bit_cnt;
    reg [15:0] baud_cnt;
    reg [9:0] shift_reg;
    reg state;

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            baud_cnt <= 0;
            bit_cnt <= 0;
            txd <= 1;
            busy <= 0;
            shift_reg <= 10'h3ff;
        end else begin
            case (state)
                0: begin 
                    txd <= 1;
                    busy <= 0;
                    if (transmit) begin
                        shift_reg <= {1'b1, data, 1'b0}; 
                        state <= 1;
                        busy <= 1;
                        baud_cnt <= 0;
                        bit_cnt <= 0;
                    end
                end
                1: begin 
                      txd <= shift_reg[0];
                    if (baud_cnt >= div_val - 1) begin
                      baud_cnt <= 0;
                        if (bit_cnt == 9) begin
                            state <= 0;
                        end else begin
                            shift_reg <= {1'b1, shift_reg[9:1]};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule
       
