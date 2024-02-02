//UART Receiver
//Simple UART Rx that uses 8 data bits, 1 start bit, 1 stop bit, no parity
//Default operation is 115200 baud
//25 MHz clock
// o_DATA_READY asserts for one clock cycle when rs data is ready to be sampled

module UART_RX #(parameter CLK_FREQ=25000000,
                 parameter BAUD_RATE=115200)
  (input i_clk,i_reset,i_serial,
   output [7:0] o_data,
   output o_rx_done);
  
  localparam CLKS_PER_BAUD = (CLK_FREQ/BAUD_RATE);
  localparam BC_MAX_WIDTH = $clog2(CLKS_PER_BAUD);
  
  localparam IDLE = 2'b00, START = 2'b01,
             DATA = 2'b10, STOP = 2'b11;
  
  reg ff_sync,serial_sync;
  reg [1:0] r_fsm,fsm_next;
  reg [BC_MAX_WIDTH-1:0] r_baud,baud_next;
  reg [2:0] r_bit,bit_next;
  reg [7:0] r_data,data_next;
  reg done;
  
  always @ (posedge i_clk)
    if(i_reset)
      begin
        ff_sync <= 0;
        serial_sync <= 0;
        r_fsm <= IDLE;
        r_baud <= 0;
        r_bit <= 0;
        r_data <= 0;
      end
    else
      begin
        ff_sync <= i_serial;
        serial_sync <= ff_sync;
        r_fsm <= fsm_next;
        r_baud <= baud_next;
        r_bit <= bit_next;
        r_data <= data_next;
      end
  
  always @ (*)
    begin
      fsm_next = r_fsm;
      baud_next = r_baud;
      bit_next = r_bit;
      data_next = r_data;
      done = 1'b0;
      
      case (r_fsm)
        IDLE:
          begin
            baud_next=0;
            bit_next=0;
            if(serial_sync == 1'b0)
              fsm_next = START;
          end
        
        START:
          if(r_baud == (CLKS_PER_BAUD/2 - 1))
             if(serial_sync == 1'b0)
               begin
                 fsm_next = DATA;
                 baud_next = 0;
               end
             else
               fsm_next = IDLE;
          else
             baud_next = r_baud + 1;
        
        DATA:
          if(r_baud == (CLKS_PER_BAUD-1))
            begin
              if(r_bit == 7)
                begin
                  fsm_next = STOP;
                  data_next = {serial_sync,r_data[7:1]};
                  baud_next = 0;
                end
              else
                begin
                  bit_next = r_bit + 1;
                  data_next = {serial_sync,r_data[7:1]};
                  baud_next = 0;  
                end
            end
          else
            baud_next = r_baud + 1;
          
             
        
        STOP:
          if(r_baud == CLKS_PER_BAUD - 1)
            begin
              fsm_next = IDLE;
              done = 1'b1;
            end
          else
            baud_next = r_baud + 1;
        
        default:
          fsm_next = IDLE;
        
      endcase
      
    end
  
  assign o_rx_done = done;
  assign o_data = r_data;
  
endmodule
