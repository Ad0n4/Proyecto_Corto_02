
module registro_divisor64 (
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift,
    input  logic [31:0] data_in,
    output logic [63:0] q
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= 64'd0;
        else if (load)
            q <= {data_in, 32'd0};
        else if (shift)
            q <= q >> 1;
    end

endmodule
