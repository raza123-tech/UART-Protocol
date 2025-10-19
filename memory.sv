module shared_mem #(
    parameter integer WIDTH = 8,
    parameter integer DEPTH = 16,
    parameter integer ADDR_WIDTH = 4
)(
    input  wire clk,
    input  wire we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [WIDTH-1:0] wdata,
    input  wire re,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output reg  [WIDTH-1:0] rdata
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;
        if (re) rdata <= mem[raddr];
    end
endmodule
