
module registro_residuo64 (
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        write_en,
    input  logic [31:0] dividendo_in,
    input  logic [63:0] data_in,
    output logic [63:0] q
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= 64'd0;
        else if (load)
            q <= {32'd0, dividendo_in};
        else if (write_en)
            q <= data_in;
    end

endmodule
