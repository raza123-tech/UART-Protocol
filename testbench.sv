
`timescale 1ns / 1ps

module tb;
    parameter CLK_FREQ  = 100_000_000;
    parameter BAUD_RATE = 9600;
    localparam CLK_PERIOD = 10;
    
    reg clk;
    reg reset;
    reg [7:0] data;
    reg transmit;
    wire txd;
    wire busy;

    transmitter #(
        .clk_freq(CLK_FREQ),
        .baud_rate(BAUD_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .transmit(transmit),
        .txd(txd),
        .busy(busy)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $display("Starting UART Transmitter Testbench...");
        $monitor("Time=%0t | txd=%b | busy=%b", $time, txd, busy);
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        reset = 0;
        transmit = 0;
        data = 8'h00;

        apply_reset();
        send_byte(8'h22);
        
        send_byte(8'hA5);

        #1000;
        $display("Testbench complete.");
        $finish;
    end

    task apply_reset;
        begin
            @(negedge clk);
            reset = 1;
            repeat(5) @(posedge clk);
            reset = 0;
            repeat(2) @(posedge clk);
            $display("--- Reset Applied ---");
        end
    endtask

    task send_byte(input [7:0] d_in);
       $display("--- Sending Data: 0x%h ---", d_in);  
      begin
            wait(!busy); 
            @(posedge clk);
            data = d_in;
            transmit = 1;
            @(posedge clk);
            transmit = 0;
           
            
            wait(busy);
            wait(!busy);
        end
    endtask





`timescale 1ns/1ps
module tb;
  reg clk;
  reg rst;
  reg rxd;
  wire [7:0] rxddata;
  wire rdone;
  
  receiver uut(
    .clk(clk),
    .rst(rst),
    .rxd(rxd),
    .rxddata(rxddata), 
    .rdone(rdone)
  );

  reg [7:0]char_in; 
  integer i;
  integer file;
  
  initial clk = 0;
  always #5 clk = ~clk;
  
  initial begin
    rxd = 1; 
    reset(); 
  
    
    file = $fopen("mem.txt", "rb"); 
    if (file == 0) begin
        $display("Error: Could not open file");
        $finish;
    end
    
  
    while (!$feof(file)) begin
      $fscanf(file, "%b", char_in); 
    end 
        #10;
      
        rxd = 0;               
        #104160;
        
        for (i = 0; i < 8; i = i + 1) begin
          rxd = char_in[i];    
          #104160;
        end
        
        rxd = 1;               
        #104160             
      
    $fclose(file);
    $display("Finished sending binary file:%0h.",rxddata);
    $finish;
  end

  task reset;
    begin
      rst = 1;
      repeat(2) @(posedge clk);
      rst = 0;
    end
  endtask

endmodule




    

endmodule
        $finish;
    end
endmodule








module uart_testbench();
    reg clk_100mhz = 0; 
    reg clk_25mhz = 0;  
    reg rst=0;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'hA5; 
    
    wire line;
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_busy;

    
    always #5  clk_100mhz = ~clk_100mhz;
    always #20 clk_25mhz  = ~clk_25mhz; 
  reg [7:0]a;  
  
  
  
  transmitter transmitter_inst (
        .clk(clk_100mhz), 
        .reset(rst),          
        .data(tx_data),       
        .transmit(tx_start),  
        .txd(line),    
        .busy(tx_busy)  
    );

  
    receiver #(
        .clk_freq(25_000_000), 
      .baud_rate(9600)      
    ) receiver_inst (
        .clk_fpga(clk_25mhz), 
        .rst(rst),            
        .rxd(line),    
        .rxddata(rx_data),    
        .rdone(rx_done)      
    );
  
  initial begin 
    $dumpfile("testbench.vcd");
    $dumpvars(0,uart_testbench);
  end
  
    initial 
      begin
        $display("Starting");
        reset();
        send($random);
        check();
        #1000 
        $finish;
 end
  
  task reset; 
    begin 
   rst=1;
        #200 
      rst = 0;
    
  end 
  endtask
  task send( input [7:0]in);
    begin 
      wait(!tx_busy);
        @(posedge clk_100mhz);
        tx_start = 1;
        tx_data = in;
        a=in;
        @(posedge clk_100mhz);
        tx_start = 0;
  
  end
  endtask
  
  task check;
    begin
   fork
            begin
                wait(rx_done);
            end
            begin
                #2000000; 
                $display("Status: Timeout reached!");
            end
        join_any

    if (rx_data == a) begin
            $display("TEST PASSED");
        end else begin
          $display("TEST FAILED:  received %h , correct %h", rx_data,a);
        end
    end
  endtask
  
endmodule

