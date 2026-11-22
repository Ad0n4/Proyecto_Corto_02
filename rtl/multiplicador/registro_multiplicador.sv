
module registro_multiplicador (
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift,
    input  logic [31:0] data_in,
    output logic [31:0] q,
    output logic        bit0
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= 32'd0;
        else if (load)
            q <= data_in;
        else if (shift)
            q <= q >> 1;
    end

    assign bit0 = q[0];

endmodule
