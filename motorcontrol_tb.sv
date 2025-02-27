`timescale 1ns/1ps

module motorcontrol_tb();

   logic clk;
   logic reset;
   logic direction;
   logic [20:0] count;
   logic pwm;

   timebase test1 (clk, reset, count);

   motorcontrol test2 (clk, reset, direction, count, pwm);

   always
      #5 clk = ~clk;  // period 10ns (100 MHz)
   initial
      clk = 0;

   initial begin
                reset = 1; direction = 0;       
     #10;       reset = 0; 
     #19999990; reset = 1; direction = 1;
     #10;       reset = 0;
     #19999990; reset = 1;                              
     #10;       reset = 0;
   end

endmodule
