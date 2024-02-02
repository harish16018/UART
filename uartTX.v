//UART Transmitter
//Simple UART Tx that uses 8 data bits, 1 start bit, 1 stop bit, no parity
//Default operation is 115200 baud
//25 MHz clock
// i_tx_DATA_READY must be asserted to start transmission when data is loaded
// o_tx_BUSY is high while tx is transmitting
// o_tx_DONE asserts for one clock when transmission is complete

module UART_TX #(parameter CLK_FREQ=25000000,
                 parameter BAUD_RATE=115200)
  (input i_clk,i_reset,i_tx_dr,
   input [7:0] i_data,
   output o_serial,o_tx_busy);
  
  localparam CLKS_PER_BAUD = (CLK_FREQ/BAUD_RATE);
  localparam BC_MAX_WIDTH = $clog2(CLKS_PER_BAUD);
  
  localparam IDLE = 2'b00, START = 2'b01,
             DATA = 2'b10, STOP = 2'b11;
  
  reg [BC_MAX_WIDTH-1:0] r_baud,baud_next;
  reg [2:0] r_bit,bit_next;
  reg [1:0] r_fsm,fsm_next;
  reg [7:0] r_data,data_next;
  reg serial;
  reg busy;
  reg baud_en;
  
  always @ (posedge i_clk)
    if(i_reset)
      begin
        r_baud <= 0;
        r_bit <= 0;
        r_fsm <= IDLE;
        r_data <= 0;
      end
    else
      begin
        r_baud <= baud_next;
        r_bit <= bit_next;
        r_fsm <= fsm_next;
        r_data <= data_next;
      end
  
  always @ (*)
    begin
      fsm_next = r_fsm;
      bit_next = r_bit;
      baud_next = r_baud;
      data_next = r_data;
      serial = 1'b1;
      busy = 1'b1;
      baud_en = 0;
      
      case (r_fsm)
        IDLE:
          begin
            busy = 1'b0;
            bit_next = 0;
            baud_next = 0;
            if(i_tx_dr)
              begin
                fsm_next = START;
                data_next = i_data;
              end
          end
        
        START:
          begin
            serial = 1'b0;
            if(r_baud == (CLKS_PER_BAUD - 1))
              begin
                baud_en = 1;
                fsm_next = DATA;
                baud_next = 0;
              end
            else
              baud_next = r_baud + 1;
          end
        
        DATA:
          begin
            serial = r_data[r_bit];
            if(r_baud == (CLKS_PER_BAUD - 1))
              begin
                if(r_bit == 7)
                  begin
                    fsm_next = STOP;
                    baud_next = 0;
                  end
                else
                  begin
                    bit_next = r_bit + 1;
                    baud_next = 0;
                  end
                baud_en = 1;
              end
            else
              baud_next = r_baud + 1;
          end
                    
        STOP:
          begin
            serial = 1'b1;
            if(r_baud == (CLKS_PER_BAUD - 1))
              begin
                baud_en = 1;
                fsm_next = IDLE;
                busy = 1'b0;
              end
            else
              baud_next = r_baud + 1;
          end
                    
        default:
          fsm_next = IDLE;
        
      endcase
    end
  
  assign o_serial = serial;
  assign o_tx_busy = busy;
  
endmodule
