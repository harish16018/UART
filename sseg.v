//This seven segment display uses a register to "hold" its value, so it can be easily viewed on the FPGA and changes its value only when the input changes
module seven_seg (input i_CLK,i_RESET,
                           input [3:0] i_BIN,
                  output [6:0] o_HEX);
  
  reg [6:0] r_hex,hex_encoding;
  
  always @ (posedge i_CLK)
    if(i_RESET)
      r_hex <= 7'b0000000;
    else
      r_hex <= hex_encoding;
  
  always @ (*)
    begin
      case (i_BIN)
          4'b0000: hex_encoding = 7'b1111110;    //0
          4'b0001: hex_encoding = 7'b0110000;    //1
          4'b0010: hex_encoding = 7'b1101101;    //2
          4'b0011: hex_encoding = 7'b1111001;    //3
          4'b0100: hex_encoding = 7'b0110011;	 //4
          4'b0101: hex_encoding = 7'b1011011;    //5
          4'b0110: hex_encoding = 7'b1011111;    //6
          4'b0111: hex_encoding = 7'b1110000;    //7
          4'b1000: hex_encoding = 7'b1111111;    //8
          4'b1001: hex_encoding = 7'b1111001;    //9
          4'b1010: hex_encoding = 7'b1110111;    //A
          4'b1011: hex_encoding = 7'b0011111;    //b
          4'b1100: hex_encoding = 7'b1001110;    //C
          4'b1101: hex_encoding = 7'b0111101;    //d
          4'b1110: hex_encoding = 7'b1001111;    //E
          4'b1111: hex_encoding = 8'b1000111;    //F
        default:
          hex_encoding = 7'b0000001; //-
      endcase
    end
  
  assign o_HEX = r_hex;
  
endmodule
          