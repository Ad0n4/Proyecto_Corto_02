
module registro_multiplicando (
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
            q <= {32'd0, data_in};
        else if (shift)
            q <= q << 1;
    end

endmodule
