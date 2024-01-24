//UART Receiver
module UART_RX #(parameter BAUD_RATE=115200,
                 parameter CLK_FREQ=25000000)
  (input i_CLK,i_RX_SERIAL,i_RESET,
   output [7:0] o_RX_DATA,
   output o_DATA_READY);
  
  localparam MAX_COUNT = (CLK_FREQ/(BAUD_RATE*16))-1;
  localparam WIDTH = $clog2(MAX_COUNT);
  
  localparam IDLE = 2'b00,
             START = 2'b01,
             DATA = 2'b10,
             STOP = 2'b11;
  
  reg DFF_1;
  reg RX_SERIAL_SYNC;
  
  reg [WIDTH-1:0] r_baud;
  wire baud_en;
  reg [3:0] r_tick,tick_next;
  reg [2:0] r_bit,bit_next;
  reg [7:0] r_data,data_next;
  reg data_ready;
  
  reg [1:0] fsm_state = 0,fsm_next;
  
  //Synchronizer
  always @ (posedge i_CLK)
    begin
      if(i_RESET)
        begin
          DFF_1 <= 0;
          RX_SERIAL_SYNC <= 0;
        end
       else
         begin
          DFF_1 <= i_RX_SERIAL;
          RX_SERIAL_SYNC <= DFF_1;
         end
    end
  
  //Oversampling baud generator
  always @ (posedge i_CLK)
      if(i_RESET)
        r_baud <= 0;
      else if(r_baud == MAX_COUNT)
        r_baud <= 0;
      else
        r_baud <= r_baud + 1;
  assign baud_en = (r_baud == MAX_COUNT);
  

  //FSM state reg
  always @ (posedge i_CLK)
    if(i_RESET)
      begin
        fsm_state <= 0;
        r_bit <= 0;
        r_tick <= 0;
        r_data <= 0;
      end
     else
       begin
         fsm_state <= fsm_next;
         r_bit <= bit_next;
         r_tick <= tick_next;
         r_data <= data_next;
       end

        
  //FSM next state and outputs
  always @ (*)
    begin
      tick_next = r_tick;
      bit_next = r_bit;
      data_next = r_data;
      data_ready = 0;
      fsm_next = fsm_state;
      
      case (fsm_state)
        IDLE:
            if(RX_SERIAL_SYNC == 1'b0)
              begin
                fsm_next = START;
                tick_next = 0;
              end  
        
        START:
            if(baud_en)
                if(r_tick == 7)
                    if(RX_SERIAL_SYNC == 1'b0)
                      begin
                        tick_next = 0;
                        bit_next = 0;
                        fsm_next = DATA;
                      end
                    else
                      fsm_next = IDLE; //Noise on serial line
                else
                  tick_next = r_tick + 1;
            

        DATA:
            if(baud_en)
                if(r_tick == 15)
                  begin
                    tick_next = 0;
                    data_next = {RX_SERIAL_SYNC,r_data[7:1]};
                    if(r_bit == 7)
                      fsm_next = STOP;
                    else
                      bit_next = r_bit + 1;
                  end
                else
                  tick_next = r_tick + 1;
           

        STOP:
            if(baud_en)
                if(tick_next == 15)
                  begin
                    data_ready = 1;
                    fsm_next = IDLE;
                  end
                else
                  tick_next = r_tick + 1;
            
        
        default:
          fsm_next = IDLE;
        
      endcase
    end
  
  assign o_RX_DATA = r_data;
  assign o_DATA_READY = data_ready;
  
endmodule