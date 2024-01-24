module UART_top_tb;
  reg i_clk,i_reset,i_uart_rx;
  wire o_uart_tx;
  
  reg [6:0] seg1, seg2;
  
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
  
  initial i_uart_rx = 1'b1;
  
  //Simulated tx of pc
  task sim_tx;
    input [7:0] d_in;
    integer i;
    reg [9:0] data_packet;;
    begin
      data_packet = {1'b1,d_in,1'b0};
      $display("Transmitting %h",d_in);
      i_uart_rx = data_packet[0];
      for (i=1;i<10;i=i+1)
        begin
          #(CLOCK_PERIOD_NS * 217);
          i_uart_rx = data_packet[i];
        end
      i_uart_rx = 1'b1;
    end
  endtask
  
  //Simulated rx of pc
  task sim_rx;
    reg [9:0] data_packet;
    integer i;
    begin
      wait(o_uart_tx == 1'b0);
      #(CLOCK_PERIOD_NS * 108);
      data_packet[0] = o_uart_tx;
      for (i=1;i<10;i=i+1)
        begin
          #(CLOCK_PERIOD_NS * 217);
          data_packet[i] = o_uart_tx;
        end
      #(CLOCK_PERIOD_NS * 108);
      $display("Received %h",data_packet[8:1]);
    end
  endtask
  
  UART_loopback_top dut (.i_clk(i_clk),.i_reset(i_reset),
                         .i_uart_rx(i_uart_rx),.o_uart_tx(o_uart_tx),
                         .o_Segment1_A(seg1[6]),
                         .o_Segment1_B(seg1[5]),
                         .o_Segment1_C(seg1[4]),
                         .o_Segment1_D(seg1[3]),
                         .o_Segment1_E(seg1[2]),
                         .o_Segment1_F(seg1[1]),
                         .o_Segment1_G(seg1[0]),
                         .o_Segment2_A(seg2[6]),
                         .o_Segment2_B(seg2[5]),
                         .o_Segment2_C(seg2[4]),
                         .o_Segment2_D(seg2[3]),
                         .o_Segment2_E(seg2[2]),
                         .o_Segment2_F(seg2[1]),
                         .o_Segment2_G(seg2[0]));
  
  task byte_from_keyboard;
    input [7:0] d_byte;
      fork
        sim_tx(d_byte);
        sim_rx;
      join 
  endtask
  
  initial
    begin
      reset;
      
      byte_from_keyboard(8'h31);
      $display("%b %b",~seg1,~seg2);
      
      byte_from_keyboard(8'h4a);
      $display("%b %b",~seg1,~seg2);
      
      byte_from_keyboard(8'hff);
      $display("%b %b",~seg1,~seg2);
      
      byte_from_keyboard(8'h12);
      $display("%b %b",~seg1,~seg2);
      
      
      $finish;
    end
  
    initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule
  
                         
                         
