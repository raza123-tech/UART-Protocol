module topmodule #(
    parameter integer CLK_FREQ = 1000000,
    parameter integer BAUD_RATE = 9600,
    parameter integer DB_THRES = 100
)(
    input  wire [7:0] data_in,
    input  wire clk,
    input  wire btn,
    input  wire reset,
    output wire txd,
    output wire [7:0] mem_out_data,
    output wire [3:0] mem_wr_addr,
    output wire tx_done_dbg,
    output wire rx_ready_dbg,
    output wire [7:0] rx_byte_dbg
);
    wire transmit_db;
    wire tx_done;
    wire [7:0] rx_byte;
    wire rx_ready;

    reg [3:0] write_addr;
    reg mem_we, mem_re;
    wire [7:0] mem_rdata;

    debouncing #(.THRESHOLD(DB_THRES)) DB (
        .clk(clk), .btn(btn), .transmit(transmit_db)
    );

    transmitter #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) TX (
        .clk(clk), .reset(reset), .data_in(data_in),
        .transmit(transmit_db), .txd(txd), .tx_done(tx_done)
    );

    receiver #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) RX (
        .clk(clk), .rst(reset), .rxd(txd), .rxddata(rx_byte), .data_ready(rx_ready)
    );

    shared_mem #(.WIDTH(8), .DEPTH(16), .ADDR_WIDTH(4)) MEM (
        .clk(clk), .we(mem_we), .waddr(write_addr), .wdata(data_in),
        .re(mem_re), .raddr(write_addr), .rdata(mem_rdata)
    );

    initial begin
        write_addr = 0;
        mem_we = 0;
        mem_re = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            write_addr <= 0;
            mem_we <= 1'b0;
            mem_re <= 1'b0;
        end else begin
            mem_we <= 1'b0;
            mem_re <= 1'b0;
            if (tx_done) begin
                mem_we <= 1'b1;
                write_addr <= write_addr + 1;
            end
            if (rx_ready) begin
                mem_re <= 1'b1;
            end
        end
    end

    assign mem_out_data = mem_rdata;
    assign mem_wr_addr = write_addr;
    assign tx_done_dbg = tx_done;
    assign rx_ready_dbg = rx_ready;
    assign rx_byte_dbg = rx_byte;

endmodule
