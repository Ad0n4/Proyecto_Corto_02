
module registro_cociente32 (
    input  logic        clk,
    input  logic        reset,
    input  logic        clear,
    input  logic        shift,
    input  logic        bit_in,
    output logic [31:0] q
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= 32'd0;
        else if (clear)
            q <= 32'd0;
        else if (shift)
            q <= {q[30:0], bit_in};
    end

endmodule
