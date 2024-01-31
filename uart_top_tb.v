//Simulates top-level loopback circuit

`include "uart_loopback_top.v"

module loopback_tb;
  reg i_clk,i_reset;
  
  wire uart_tx_serial,uart_rx_serial;
  
  reg tx_dr;
  reg [7:0] tx_data;
  
  wire [7:0] rx_data;
  wire rx_dr;
  
  UART_TX pcInstTx (.i_CLK(i_clk),
                  .i_RESET(i_reset),
                  .i_tx_DATA_READY(tx_dr),
                  .i_tx_DATA(tx_data),
                  .o_tx_SERIAL(uart_tx_serial));
  
  UART_RX pcInstRx (.i_CLK(i_clk),
                 .i_RESET(i_reset),
                 .i_RX_SERIAL(uart_rx_serial),
                 .o_RX_DATA(rx_data),
                 .o_DATA_READY(rx_dr));
  
    localparam CLOCK_PERIOD_NS = 40;
  
  //25 MHz clock
  always
    begin
      #(CLOCK_PERIOD_NS/2) i_clk <= 1'b0;
      #(CLOCK_PERIOD_NS/2) i_clk <= 1'b1;
    end
  
  //Reset
  task reset;
    begin
      i_reset = 1'b0;
      wait(i_clk !== 1'bx);
      @(negedge i_clk);
      i_reset <= 1'b1;
      @(negedge i_clk);
      i_reset <= 1'b0;
    end
  endtask
    
  UART_loopback_top dut (.i_clk(i_clk),.i_reset(i_reset),
                         .i_uart_rx(uart_tx_serial),.o_uart_tx(uart_rx_serial));
  
  task sim_serial;
    input [7:0] d_in;
    begin
      $display("Transmitting from PC %h",d_in);
      tx_data <= d_in;
      tx_dr <= 1'b1;
      @(posedge i_clk);
      @(posedge i_clk);
      tx_dr <= 1'b0;
      @(posedge rx_dr);
      $display("Received at PC %h",rx_data); 
    end
  endtask
  
  initial
    begin
      reset;
      
      #950;
      sim_serial(8'h53);    
      
      #950;
      sim_serial(8'h53); 
      
      #900;
      sim_serial(8'h53); 
      
      #850;
      sim_serial(8'h61); 

      #769;
      sim_serial(8'h61); 
      
      $finish;
    end
  
    initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule
