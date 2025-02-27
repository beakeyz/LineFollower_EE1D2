// One timebase count = 10 ns
// These values are from the slides. Are they relevant?
`define MOTOR_CTL_F_CCW_PW_TB_COUNTS (100 * 1000) /* Pulse time in nanoseconds (1ms) */
`define MOTOR_CTL_CCW_PW_TB_COUNTS (120 * 1000) /* Pulse time in nanoseconds (1.2ms) */
`define MOTOR_CTL_STOP_PW_TB_COUNTS (150 * 1000) /* Pulse time in nanoseconds (1.5ms) */
`define MOTOR_CTL_CW_PW_TB_COUNTS (170 * 1000) /* Pulse time in nanoseconds (1.7ms) */
`define MOTOR_CTL_F_CW_PW_TB_COUNTS (200 * 1000) /* Pulse time in nanoseconds (2ms) */

typedef enum logic[1:0] { 
    MOTOR_CTL_STATE_CCW = 0,
    MOTOR_CTL_STATE_CW = 1,
    MOTOR_CTL_STATE_STOP = 2
} MOTOR_CTL_STATE;

/**
 * The motor controller is the module that generates the correct PWM signal for a single motor, based
 * on what info it gets from the robot controller
 *
 * NOTE: This is a mealy machine, but it should work. If there are any issues with this module in the future,
 * consider transforming to a moore machine with the states MOTOR_RESET, MOTOR_ON and MOTOR_OFF to drive the
 * pwm pulse
 *
 * @clk: Clock signal (100Mhz)
 * @reset: reset the FSM
 * @direction: Which direction should the motor go (clockwise = 1 or counterclockwise = 0)
 * @count_in: Time count provided by the timebase
 * @pwm: Output PWM signal
 */
module motorcontrol 
   (input logic clk,
    input logic reset,
    input logic direction, 
    input logic [20:0] count_in,
    output logic pwm);

    MOTOR_CTL_STATE next_motor_state;
    MOTOR_CTL_STATE motor_state;

    always_ff @( posedge clk ) begin : state_logic
        motor_state <= next_motor_state;
    end

    always_comb begin
        /* Reset overrules the motor state to stop */
        if (reset)
            next_motor_state = MOTOR_CTL_STATE_STOP;
        else begin
            /* Check the direction */
            if (direction)
                next_motor_state = MOTOR_CTL_STATE_CW;
            else
                next_motor_state = MOTOR_CTL_STATE_CCW;
        end

        case (motor_state)
            MOTOR_CTL_STATE_CW:
                if (count_in <= `MOTOR_CTL_F_CW_PW_TB_COUNTS) pwm = 1;
                else pwm = 0;
            MOTOR_CTL_STATE_CCW:
                if (count_in <= `MOTOR_CTL_F_CCW_PW_TB_COUNTS) pwm = 1;
                else pwm = 0;
            MOTOR_CTL_STATE_STOP:
                pwm = 0;
        endcase
    end

endmodule
