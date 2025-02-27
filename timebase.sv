module timebase 
   (input logic clk,
    input logic reset,
    output logic [20:0] count);

    logic [20:0] _next_count;

    // Export the next count into the output
    always_ff @( posedge clk ) begin
        if (reset == 1)
            count <= 0;
        else
            count <= _next_count;

    end

    always_comb begin
        _next_count = count + 1;
    end

endmodule
