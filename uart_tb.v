//Tb exercises tx and rx

`include "uartRX.v"
`include "uartTX.v"

module UART_tb; 
  reg i_clk;
  reg i_tx_dr,i_reset;
  reg [7:0] i_tx_data;
  wire uart_serial,o_tx_busy;
  wire [7:0] o_rx_data;
  wire o_rx_dr;
  
  
  localparam CLOCK_PERIOD_NS = 40;
  
  UART_tx uut (.i_clk(i_clk),
              .i_tx_dr(i_tx_dr),
              .i_data(i_tx_data),
               .i_reset(i_reset),
              .o_serial(uart_serial),
               .o_tx_busy(o_tx_busy));
  
  UART_rx rx_inst (.i_clk(i_clk),
                   .i_reset(i_reset),
                  .i_serial(uart_serial),
                  .o_data(o_rx_data),
                  .o_rx_done(o_rx_dr));
  
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
      
      data_transfer(8'h53);
      
      @(negedge o_tx_busy);
      data_transfer(8'h61);

      @(negedge o_tx_busy);
      data_transfer(8'h4a);
      
      @(negedge o_tx_busy);
      data_transfer(8'h1);

      @(negedge o_tx_busy);
      data_transfer(8'h2d);
      
      $finish;
    end
      

  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule
