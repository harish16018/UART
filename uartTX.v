//UART Transmitter
module UART_TX #(parameter BAUD_RATE = 115200,
                 parameter CLK_FREQ = 25000000)
  
  (input i_CLK,i_RESET,i_tx_DATA_READY,
   input [7:0] i_tx_DATA,
   output o_tx_SERIAL,o_tx_BUSY,o_tx_DONE);
  
  localparam CLK_PER_BIT = CLK_FREQ/BAUD_RATE; //cyc per bit ~217 for 115200 baud at 25Mhz
  localparam MAX_COUNT = CLK_PER_BIT-1;
  localparam WIDTH = $clog2(CLK_PER_BIT);
  
  localparam IDLE = 2'b00,
             START = 2'b01,
             DATA = 2'b10,
             STOP = 2'b11;
  
  reg [WIDTH-1:0] r_baud;
  wire baud_en;
  reg [7:0] tx_r,tx_next;
  reg tx_busy;
  reg tx_done;
  reg [1:0] fsm_state,fsm_next;
  reg [2:0] r_bit,bit_next;
  reg tx_serial;
  
    
  //Baud generator
  always @ (posedge i_CLK)
    if(i_RESET)
      r_baud <= 0;
    else if (r_baud == MAX_COUNT)
      r_baud <= 0;
    else
      r_baud <= r_baud + 1;
  assign baud_en = (r_baud == MAX_COUNT);
  
  //FSM state reg
  always @ (posedge i_CLK)
    if(i_RESET)
      begin
        fsm_state <= IDLE;
        r_bit <= 0;
        tx_r <= 0;
      end
  else
    begin
      fsm_state <= fsm_next;
      r_bit <= bit_next;
      tx_r <= tx_next;
    end

  
  //FSM next state and output
  always @ (*)
    begin
      fsm_next = fsm_state;
      tx_next = tx_r;
      bit_next = r_bit;
      tx_busy = 1'b1;
      tx_done = 1'b0;
      
      case (fsm_state)
        IDLE:
          begin
            tx_serial = 1'b1;
            bit_next = 0;
            tx_busy = 1'b0;
            if(i_tx_DATA_READY)
              begin
                tx_next = i_tx_DATA;
                fsm_next = START;
              end 
          end
        
        START:
            begin
              tx_serial = 1'b0;
              if(baud_en)
                fsm_next = DATA;
            end 
        
        DATA:
          begin
            tx_serial = tx_r[r_bit];
            if(baud_en)
              if(r_bit == 7)
                fsm_next = STOP;
              else
                begin
                  bit_next = r_bit + 1;
                  fsm_next = DATA;
                end
          end 
        
        STOP:
          begin
            tx_serial = 1'b1;
            if(baud_en)
              begin
                tx_done = 1'b1;
                tx_busy = 1'b0;
                fsm_next = IDLE;
              end
          end 
        
        default:
          fsm_next = IDLE;
      endcase
    end
  
  assign o_tx_SERIAL = tx_serial;
  assign o_tx_DONE = tx_done;
  assign o_tx_BUSY = tx_busy;
  
endmodule