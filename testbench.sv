`timescale 1ns/1ps


`include "transaction.sv"
`include "interface.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "environment.sv"

module tb_top;


  bit clk;
  bit rst;


  always #5 clk = ~clk;

 
  uart_intf intf(clk, rst);

  uart_top dut (
    .clk      (intf.clk),
    .rst      (intf.rst),
    .tx_data  (intf.tx_data),
    .transmit (intf.transmit),
    .txd      (intf.txd),
    .busy     (intf.busy),
    .rx_data  (intf.rx_data),
    .rdone    (intf.rdone),
    .rxd      (intf.rxd)
  );

 
  assign intf.rxd = intf.txd;

 
  environment env;

 
  initial begin
   
    clk = 0;
    rst = 1;
    
   
    #20;
    rst = 0;
    
   
    env = new(intf.tb);
    
    
    env.gen.rcount = 500;
    
   
    env.run();
  end

 
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule


// TRANSACTION

class transaction;
  rand bit [7:0] tx_data;
  bit [7:0] rx_data;
  bit busy;
  bit rdone;
​
 
  constraint coverage {
    tx_data dist {
      8'h00      := 10,  
      [1:254]    :/ 80,  
      8'hFF      := 10   
    };
  }
​
  function void display(string name);
    $display("[%s] time=%0t | tx_data: %0d | rx_data: %0d | busy: %b | rdone: %b", 
              name, $time, tx_data, rx_data, busy, rdone);
  endfunction
  
endclass 

// INTERFACE

interface uart_intf(input logic clk, input logic rst);
  
 
  logic [7:0] tx_data;  
  logic       transmit; 
  logic       txd;     
  logic       busy;    
  
  logic [7:0] rx_data; 
  logic       rdone;   
  logic       rxd;     

 
   
  

  modport tb (
    input  clk, rst,
    output tx_data, transmit, 
    input  txd, busy,         
    input  rx_data, rdone,    
    output rxd                
  );

 
  
  modport dut (
    input  clk, rst,
    input  tx_data, transmit, rxd,
    output txd, busy, rx_data, rdone
  );

endinterface

// GENERATOR

class generator;
  transaction trans;
  mailbox #(transaction) gen2drv;
  int rcount;
  event ended; 

  function new(mailbox#(transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  
 task run();
    repeat(rcount) begin
      trans = new();
      if(!trans.randomize()) $error("Randomization failed");
      gen2drv.put(trans);
      trans.display("Generator");
     
      #100; 
    end
    #500;
    -> ended; 
  endtask
endclass

// DRIVER
class driver;
  virtual uart_intf.tb vif;
  mailbox#(transaction) gen2drv;
  
  function new(virtual uart_intf.tb vif, mailbox#(transaction) gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction
  
  task run(); 
    forever begin
      transaction trans;
      
      
      gen2drv.get(trans);
      
    
      wait(vif.busy == 0);
      
     
      @(posedge vif.clk);
      vif.tx_data  <= trans.tx_data; 
      vif.transmit <= 1;
      
      
      @(posedge vif.clk);
      vif.transmit <= 0;
      
     
      wait(vif.busy == 1); 
      wait(vif.busy == 0); 
      
      trans.display("Driver");
    end
  endtask
endclass

// MONITOR

class monitor;
  virtual uart_intf.tb vif;
  mailbox #(transaction) mon2scb; 

  function new(virtual uart_intf.tb vif, mailbox#(transaction) mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task run(); 
    forever begin
      transaction trans = new();
      
     
      wait(vif.rdone == 1);  
      
     
      @(posedge vif.clk);
      
     
      trans.tx_data = vif.tx_data; 
      trans.rx_data = vif.rx_data; 
      trans.rdone   = vif.rdone;   
      
     
      mon2scb.put(trans);
      trans.display("Monitor"); 
      
      
      wait(vif.rdone == 0);
    end
  endtask
endclass

// SCOREBOARD
class scoreboard;
  
  mailbox#(transaction) mon2scb;
  int count = 0;
  int pass  = 0;
  int fail  = 0;
  
  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task run(); 
    transaction trans;
    forever begin
      
      mon2scb.get(trans);
      
      
      if(trans.tx_data == trans.rx_data) begin
        $display("SCOREBOARD PASS | Time: %0t | Expected: %0d | Actual: %0d", 
                  $time, trans.tx_data, trans.rx_data);
        pass++;
      end
      else begin
        $display("SCOREBOARD FAIL | Time: %0t | Expected: %0d | Actual: %0d", 
                  $time, trans.tx_data, trans.rx_data);
        fail++;
      end
      
      count++;
    end
  endtask
endclass


// ENVIRONMENT

class environment;
 
  generator      gen;
  driver         drv;
  monitor        mon;
  scoreboard     scb;
  uart_coverage  cov; 
  
 
  virtual uart_intf.tb vif;
  
  
  mailbox #(transaction) gen2drv;
  mailbox #(transaction) mon2scb;

  
  function new(virtual uart_intf.tb vif);
   
    this.vif = vif;
    
   
    gen2drv = new();
    mon2scb = new();
      
 
    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
    cov = new();      
  endfunction

 
  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
      
      forever begin
        transaction item;
        mon2scb.peek(item);   
        cov.sample(item);     
        @(posedge vif.rdone);
      end
      
    
      begin
        #1000000; 
        $display( "timeout check your logic");
      end
    join_any 

    wait(scb.count == gen.rcount); 
    #1000; 
    
  
    $display("  verificaytion done");
    $display("  total packet send : %0d", scb.count);
    $display("  Pass: %0d | Fail: %0d", scb.pass, scb.fail);
    $display("  Final Coverage: %0.2f%%", cov.data_cg.get_inst_coverage());
   
    $finish; 
  endtask
endclass

//COVERAGE

class uart_coverage;
  transaction trans;

  covergroup data_cg;
    
    coverpoint trans.rx_data {
      bins low    = {[0:85]};
      bins mid    = {[86:170]};
      bins high   = {[171:255]};
      
     
      bins zero      = {8'h00};
      bins max       = {8'hFF};
      bins toggle_55 = {8'h55};
      bins toggle_AA = {8'hAA};
    }

   
    cp_rdone: coverpoint trans.rdone {
      bins hit_done = {1};
    }
  endgroup

  function new();
    data_cg = new();
  endfunction

 
  function void sample(transaction t);
    this.trans = t;
    data_cg.sample();
  endfunction
endclass



