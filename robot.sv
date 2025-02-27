`include "motorcontrol.sv"
`include "controller.sv"
`include "timebase.sv"

module robot
   (input logic clk,
    input logic reset,

    input logic sensor_l_in,
    input logic sensor_m_in,
    input logic sensor_r_in,

    output logic motor_l_pwm,
    output logic motor_r_pwm);

    // Sensor parameter
    sensor_data_t buffered_data;

    // Timebase parameters
    logic [20:0] tb_count;
    logic tb_reset;

    // Motor controller parameters
    logic mtr_lrst, mtr_rrst;
    logic mtr_ldir, mtr_rdir;

    // Input buffer to get data from the sensor
    inputbuffer buffer(
        .clk(clk),
        .sensor_l_in(sensor_l_in),
        .sensor_m_in(sensor_m_in),
        .sensor_r_in(sensor_r_in),
        .sensor_l_out(buffered_data.left),
        .sensor_m_out(buffered_data.middle),
        .sensor_r_out(buffered_data.right)
    );

    // Timebase so we're not completely lost
    timebase tb(
        .clk(clk),
        .reset(tb_reset),
        .count(tb_count)
    );

    // Define the master controller
    controller ctl(
        .clk(clk),
        .reset(reset),
        .sdata(buffered_data),
        .count_in(tb_count),
        .count_reset(tb_reset),
        .motor_l_reset(mtr_lrst),
        .motor_l_direction(mtr_ldir),
        .motor_r_reset(mtr_rrst),
        .motor_r_direction(mtr_rdir)
    );

    // Define the left side motor controller
    motorcontrol mctl_left(
        .clk(clk),
        .reset(mtr_lrst),
        .direction(mtr_ldir),
        .count_in(tb_count),
        .pwm(motor_l_pwm)
    );

    // Define the right side motor controller
    motorcontrol mctl_right(
        .clk(clk),
        .reset(mtr_rrst),
        .direction(mtr_rdir),
        .count_in(tb_count),
        .pwm(motor_r_pwm)
    );
endmodule
