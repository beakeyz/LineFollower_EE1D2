/**
 * Stores the sensor data in a 3-bit struct
 */
typedef struct packed {
    // Does the left sensor see a black line
    logic left;
    // Does the middle sensor see a black line
    logic middle;
    // Does the right sensor see a black line
    logic right;
} sensor_data_t;

`define SDATA_HAS(d, code) (d == sensor_data_t'(code))

/**
 * Define the sensor data
 * states
 */
typedef enum logic {
    SENS_BLACK = 0,
    SENS_WHITE = 1
} SENSOR_DATA;

/*!
 * Register to save our sensor data
 */
module sensor_reg(
    input logic clk,
    input sensor_data_t data,
    input logic wr,
    output sensor_data_t out_data
);
    sensor_data_t internal_data;

    /* If we're writing data, put data into internal_data */
    always_ff @( posedge clk )
        if (wr) internal_data <= data;

    /* Export the internal data to the outside world! */
    assign out_data = internal_data;
endmodule


module inputbuffer
   (input logic clk,
    input logic sensor_l_in,
    input logic sensor_m_in, 
    input logic sensor_r_in,
    output logic sensor_l_out,
    output logic sensor_m_out, 
    output logic sensor_r_out);

    sensor_data_t data1;
    sensor_data_t data2;

    sensor_reg reg1(
        .clk(clk),
        .data({
            sensor_l_in,
            sensor_m_in,
            sensor_r_in
        }),
        .wr(1'b1),
        .out_data(data1)
    );

    sensor_reg reg2(
        .clk(clk),
        .data(data1),
        .wr(1'b1),
        .out_data(data2)
    );

    assign sensor_l_out = data2.left;
    assign sensor_m_out = data2.middle;
    assign sensor_r_out = data2.right;
endmodule
