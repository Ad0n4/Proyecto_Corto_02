
module alu_divisor64 (
    input  logic [63:0] residuo,
    input  logic [63:0] divisor,
    output logic [63:0] diferencia,
    output logic        negativo
);

    logic [64:0] resta_extendida;

    // Resta de 65 bits para detectar prestamo
    assign resta_extendida =
        {1'b0, residuo} - {1'b0, divisor};

    assign diferencia = resta_extendida[63:0];
    assign negativo = resta_extendida[64];

endmodule
