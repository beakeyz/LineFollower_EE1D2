`timescale 1ns/1ps

module timebase_tb();

   logic clk;
   logic reset;
   logic [20:0] count;

   timebase test (clk, reset, count);

   always
      #5 clk = ~clk;
   initial
      clk = 0;

   initial begin
          reset = 1; 
     #10; reset = 0; 
   end

endmodule
