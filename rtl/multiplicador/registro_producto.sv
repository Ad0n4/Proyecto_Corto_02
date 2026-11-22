
module registro_producto (
    input  logic        clk,
    input  logic        reset,
    input  logic        clear,
    input  logic        write_en,
    input  logic [63:0] data_in,
    output logic [63:0] q
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= 64'd0;
        else if (clear)
            q <= 64'd0;
        else if (write_en)
            q <= data_in;
    end

endmodule
