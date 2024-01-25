//Tb exercises tx and rx

`include "uartRX.v"
`include "uartTX.v"

module UART_tb; 
  reg i_clk;
  reg i_tx_dr,i_reset;
  reg [7:0] i_tx_data;
  wire uart_serial,o_tx_busy, o_tx_done;
  wire [7:0] o_rx_data;
  wire o_rx_dr;
  
  
  localparam CLOCK_PERIOD_NS = 40;
  
  UART_TX uut (.i_CLK(i_clk),
              .i_tx_DATA_READY(i_tx_dr),
              .i_tx_DATA(i_tx_data),
               .i_RESET(i_reset),
              .o_tx_SERIAL(uart_serial),
              .o_tx_BUSY(o_tx_busy),
              .o_tx_DONE(o_tx_done));
  
  UART_RX rx_inst (.i_CLK(i_clk),
                   .i_RESET(i_reset),
                  .i_RX_SERIAL(uart_serial),
                  .o_RX_DATA(o_rx_data),
                  .o_DATA_READY(o_rx_dr));
  
  //Generate 25 MHz clk
  always
    begin
      #(CLOCK_PERIOD_NS/2) i_clk <= 1'b0;
      #(CLOCK_PERIOD_NS/2) i_clk <= 1'b1;
    end
  
  //System reset
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
  
  task tx_byte; //Loads and transmits byte
    input [7:0] d_in;
    begin
      i_tx_data = d_in;
      @(negedge i_clk);
      i_tx_dr=1'b1;
      repeat(2)
        @(negedge i_clk);
      i_tx_dr=1'b0;
    end
  endtask
  
  task rx_byte; //Checks if received byte is correct
    input [7:0] d_in;
    begin
      @(posedge o_rx_dr);
      if(o_rx_data == d_in)
        $display("Correct byte received");
      else
        $display("Incorrect byte %h received instead of %h",o_rx_data,d_in); 
    end
  endtask
  
  task data_transfer;
    input [7:0] d_in;
    begin
      fork
        tx_byte(d_in);
        rx_byte(d_in);
      join
    end
  endtask
  
  initial
    begin
      reset;
      
      data_transfer(8'h31);
      
      @(posedge o_tx_done);
      data_transfer(8'hff);

      @(posedge o_tx_done);
      data_transfer(8'h4a);
      
      @(posedge o_tx_done);
      data_transfer(8'h1);

      @(posedge o_tx_done);
      data_transfer(8'h2d);
      
      $finish;
    end
      

  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule
      
      
      
