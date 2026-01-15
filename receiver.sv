module receiver #(
    parameter clk_freq    = 50000000,
    parameter baud_rate   = 9600,
    parameter div_sample  = 4
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rxd,
    output reg [7:0]  rxddata, 
    
   
);
    localparam div_counter = clk_freq / (baud_rate * div_sample);
    localparam mid_sample  = div_sample / 2;

    reg        state; 
    reg [3:0]  bit_count;
    reg [2:0]  sample_count;
    reg [15:0] baud_tick_cnt;
    reg [7:0]  rx_shift_reg; 

    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            baud_tick_cnt <= 0;
            sample_count <= 0;
            bit_count <= 0;
            rdone <= 0;
            rxddata <= 0;
            rx_shift_reg <= 0;
        end else begin
            rdone <= 0; 
            baud_tick_cnt <= baud_tick_cnt + 1;
            
            if (baud_tick_cnt >= div_counter - 1) begin
                baud_tick_cnt <= 0;
                
                case (state)
                    0: begin
                        
                      if (!rxd) begin
                            state <= 1;
                            sample_count <= 0;
                            bit_count <= 0;
                             
                        end
                    end

                    1: begin 
                     
                        if (sample_count == div_sample - 1) begin
                            sample_count <= 0;
                            if (bit_count == 9) begin 
                                state <= 0;
                            end else begin
                                bit_count <= bit_count + 1;
                            end
                        end else begin
                            sample_count <= sample_count + 1;
                        end

                        if (sample_count == mid_sample) begin
                            if (bit_count >= 1 && bit_count <= 8) begin
                                rx_shift_reg <= {rxd, rx_shift_reg[7:1]};
                            end
                            if (bit_count == 8) begin
                                rxddata <= {rxd, rx_shift_reg[7:1]}; 
                                rdone <= 1;
                            end
                        end
                    end
                endcase
            end
        end
    end
endmodule
