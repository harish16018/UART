//This top-level circuit verifies the working of the UART using a loopback. 
//It displays the ASCII value of the transmitted character in hex on a seven-segment display and echoes it back to the pc

`include "uartRX.v"
`include "uartTX.v"
`include "sseg.v"


module UART_loopback_top (input i_clk, i_reset,
                          input i_uart_rx,
                          output o_uart_tx,
   output o_Segment1_A, //Segment 1 is upper digit of Rx output
   output o_Segment1_B,
   output o_Segment1_C,
   output o_Segment1_D,
   output o_Segment1_E,
   output o_Segment1_F,
   output o_Segment1_G,

   output o_Segment2_A, //Segment 2 is lower digit of Rx output
   output o_Segment2_B,
   output o_Segment2_C,
   output o_Segment2_D,
   output o_Segment2_E,
   output o_Segment2_F,
   output o_Segment2_G);   
                                              
  
  wire rx_data_ready;
  wire [7:0] rx_data;
  
  wire tx_busy;
  wire tx_serial;
  
  wire [6:0] seg1, seg2;
  
  UART_TX uart_tx_inst (.i_clk(i_clk),.i_reset(i_reset),
                        .i_tx_dr(rx_data_ready),
                        .i_data(rx_data),
                        .o_serial(tx_serial),
                        .o_tx_busy(tx_busy));
  
  UART_RX uart_rx_inst (.i_clk(i_clk),.i_reset(i_reset),
                        .i_serial(i_uart_rx),
                        .o_data(rx_data),
                        .o_rx_done(rx_data_ready));
  
  assign o_uart_tx = tx_serial;
  
  seven_seg segment1 (.i_bin(rx_data[7:4]),
                   .o_hex(seg1));
  
  seven_seg segment2 (.i_bin(rx_data[3:0]),
                  .o_hex(seg2)); 
  
  assign o_Segment1_A = ~seg1[6]; //Seven segment display used uses active-low signals
  assign o_Segment1_B = ~seg1[5];
  assign o_Segment1_C = ~seg1[4];  
  assign o_Segment1_D = ~seg1[3];                   
  assign o_Segment1_E = ~seg1[2];                        
  assign o_Segment1_F = ~seg1[1];                        
  assign o_Segment1_G = ~seg1[0];  
  
  
  assign o_Segment2_A = ~seg2[6]; 
  assign o_Segment2_B = ~seg2[5];
  assign o_Segment2_C = ~seg2[4];  
  assign o_Segment2_D = ~seg2[3];                   
  assign o_Segment2_E = ~seg2[2];                        
  assign o_Segment2_F = ~seg2[1];                        
  assign o_Segment2_G = ~seg2[0]; 
  
endmodule
