`timescale 1ns/1ps

module inputbuffer_tb();

   logic clk;

   logic a, b, c;
   logic a_out, b_out, c_out;
   
   inputbuffer buff(clk, a, b, c, a_out, b_out, c_out);

   always
      #5 clk = ~clk;  // period 10ns (100 MHz)
   initial
      clk = 0;

   initial begin
      assign a = 0;
      assign b = 1;
      assign c = 0;

      #10 assign a = 1;

      #20 assign a = 0;
      assign b = 0;
      assign c = 1;
   end

endmodule
