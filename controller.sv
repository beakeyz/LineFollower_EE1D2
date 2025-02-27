`include "inputbuffer.sv"

typedef enum logic[3:0] { 
    CTL_STATE_IDLE = 0,
    CTL_STATE_FORWARD = 1,
    CTL_STATE_L = 2,
    CTL_STATE_SL = 3,
    CTL_STATE_R = 4,
    CTL_STATE_SR = 5
} CTL_STATE;

module controller 
   (input logic clk,
    input logic reset,

    input sensor_data_t sdata,

    input logic [20:0] count_in,
    output logic count_reset,

    output logic motor_l_reset,
    output logic motor_l_direction,

    output logic motor_r_reset,
    output logic motor_r_direction);

    CTL_STATE state;
    CTL_STATE nx_state;

    always_ff @(posedge clk)
        if (reset) state <= CTL_STATE_IDLE;
        else state <= nx_state;

    always_comb begin : cmb
        case (state)
            /**
             * FIXME: Smarter way to select states?
             */
            CTL_STATE_IDLE: begin
                // Detected a line in front AND to our left. Do a gentle left turn
                if (`SDATA_HAS(sdata, 3'b001)) nx_state = CTL_STATE_L;
                // Detected a line to our left. Do a sharp left turn
                else if (`SDATA_HAS(sdata, 3'b011)) nx_state = CTL_STATE_SL;
                // Detected a line in front AND to our right. Do a gentle right turn
                else if (`SDATA_HAS(sdata, 3'b100)) nx_state = CTL_STATE_R;
                // Detected a line to our right. Do a sharp right turn
                else if (`SDATA_HAS(sdata, 3'b110)) nx_state = CTL_STATE_SR;
                // Only a otherwise simply go forward
                else nx_state = CTL_STATE_FORWARD;
            end
            // Just go back to evaluate again next clk cycle
            default: begin 
                if (count_in <= 200_000) nx_state = state;
                else nx_state = CTL_STATE_IDLE;
            end
        endcase

        // If we want to do a normal left, stop the left wheel
        motor_l_reset = (state == CTL_STATE_L | state == CTL_STATE_IDLE);
        // If we want to do a normal right, stop the right wheel
        motor_r_reset = (state == CTL_STATE_R | state == CTL_STATE_IDLE);

        // 1 = clockwise, 0 = counterclockwise
        motor_l_direction = (state != CTL_STATE_SL);
        motor_r_direction = (state == CTL_STATE_SR);

        // Reset the timebase when we reach 2 milion
        count_reset = reset | (count_in >= 2_000_000);
    end

endmodule
   
