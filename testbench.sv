
module tb_uart_shared;
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg btn;

    wire txd;
    wire [7:0] mem_out_data;
    wire [3:0] mem_wr_addr;
    wire tx_done_dbg;
    wire rx_ready_dbg;
    wire [7:0] rx_byte_dbg;

    integer i;
    integer tcnt;
    integer max_wait;
    reg [7:0] test_bytes [0:3];

    topmodule #(.CLK_FREQ(1000000), .BAUD_RATE(9600), .DB_THRES(20)) DUT (
        .data_in(data_in),
        .clk(clk),
        .btn(btn),
        .reset(reset),
        .txd(txd),
        .mem_out_data(mem_out_data),
        .mem_wr_addr(mem_wr_addr),
        .tx_done_dbg(tx_done_dbg),
        .rx_ready_dbg(rx_ready_dbg),
        .rx_byte_dbg(rx_byte_dbg)
    );

    initial begin
        clk = 0;
        forever #500 clk = ~clk;
    end

    initial begin
        $dumpfile("uart_iv.vcd");
        $dumpvars(0, tb_uart_shared);
    end

    initial begin
        reset = 1'b1;
        btn = 1'b0;
        data_in = 8'h00;

        test_bytes[0] = 8'h55;
        test_bytes[1] = 8'hA5;
        test_bytes[2] = 8'h00;
        test_bytes[3] = 8'hFF;

        #2000;
        reset = 1'b0;

        for (i = 0; i < 4; i = i + 1) begin
            data_in = test_bytes[i];

            btn = 1'b1;
            repeat (200) @(posedge clk);
            btn = 1'b0;

            tcnt = 0;
            max_wait = 50000;
            while (tx_done_dbg == 1'b0) begin
                @(posedge clk);
                tcnt = tcnt + 1;
                if (tcnt >= max_wait) begin
                    $display("ERROR: TIMEOUT waiting for tx_done for byte %0d (%02h) at sim time %0t", i, data_in, $time);
                    $finish;
                end
            end
            $display("TB: TX done for byte %0d: %02h at time %0t", i, data_in, $time);

            tcnt = 0;
            while (rx_ready_dbg == 1'b0) begin
                @(posedge clk);
                tcnt = tcnt + 1;
                if (tcnt >= max_wait) begin
                    $display("ERROR: TIMEOUT waiting for rx_ready for byte %0d (%02h) at sim time %0t", i, data_in, $time);
                    $finish;
                end
            end
            @(posedge clk);

            if (rx_byte_dbg === data_in) $display("PASS: Sent %02h, Received %02h (time %0t)", data_in, rx_byte_dbg, $time);
            else $display("FAIL: Sent %02h, Received %02h (time %0t)", data_in, rx_byte_dbg, $time);

            repeat (300) @(posedge clk);
        end

        $display("All tests finished at time %0t", $time);
        $finish;
    end
endmodule

