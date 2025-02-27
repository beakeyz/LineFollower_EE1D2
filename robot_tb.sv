`timescale 1ns/1ps
`include "robot.sv"

module robot_tb();

   logic clk;
   logic reset;
   logic sensor_l;
   logic sensor_m;
   logic sensor_r;
   logic [2:0] sensors;
   logic motor_l_pwm, motor_r_pwm;

   robot test (clk, reset, sensor_l, sensor_m, sensor_r, 
                                motor_l_pwm, motor_r_pwm);

   assign {sensor_l, sensor_m, sensor_r} = sensors;

   always
      #5ns clk = ~clk;  // period 10ns (100 MHz)
   initial
      clk = 0;

   initial begin
     #0ms;  reset = 1; 
     #40ms; reset = 0; 
   end

   initial begin
     #0ms;  sensors = 3'b000; 
     #70ms; sensors = 3'b001; 
     #40ms; sensors = 3'b010; 
     #40ms; sensors = 3'b011; 
     #40ms; sensors = 3'b100; 
     #40ms; sensors = 3'b101; 
     #40ms; sensors = 3'b110; 
     #40ms; sensors = 3'b111; 
   end

endmodule
