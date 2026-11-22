
module divisor32 (
    input  logic        clk,
    input  logic        reset,
    input  logic        start,
    input  logic [31:0] dividendo,
    input  logic [31:0] divisor,

    output logic [31:0] cociente,
    output logic [31:0] residuo,
    output logic        busy,
    output logic        done,
    output logic        div_zero
);

    // Senales internas
    logic [63:0] divisor_actual;
    logic [63:0] residuo_actual;
    logic [63:0] diferencia;
    logic [31:0] cociente_actual;
    logic negativo;

    logic load_operands;
    logic clear_quotient;
    logic shift_divisor;
    logic shift_quotient;
    logic write_remainder;
    logic bit_cociente;

    // Unidad de control
    control_divisor u_control (
        .clk(clk),
        .reset(reset),
        .start(start),
        .negativo(negativo),
        .divisor_cero(divisor == 32'd0),

        .load_operands(load_operands),
        .clear_quotient(clear_quotient),
        .shift_divisor(shift_divisor),
        .shift_quotient(shift_quotient),
        .write_remainder(write_remainder),
        .bit_cociente(bit_cociente),
        .busy(busy),
        .done(done),
        .div_zero(div_zero)
    );

    // Registro del divisor
    registro_divisor64 u_divisor (
        .clk(clk),
        .reset(reset),
        .load(load_operands),
        .shift(shift_divisor),
        .data_in(divisor),
        .q(divisor_actual)
    );

    // Registro del residuo
    registro_residuo64 u_residuo (
        .clk(clk),
        .reset(reset),
        .load(load_operands),
        .write_en(write_remainder),
        .dividendo_in(dividendo),
        .data_in(diferencia),
        .q(residuo_actual)
    );

    // ALU de resta
    alu_divisor64 u_alu (
        .residuo(residuo_actual),
        .divisor(divisor_actual),
        .diferencia(diferencia),
        .negativo(negativo)
    );

    // Registro del cociente
    registro_cociente32 u_cociente (
        .clk(clk),
        .reset(reset),
        .clear(clear_quotient),
        .shift(shift_quotient),
        .bit_in(bit_cociente),
        .q(cociente_actual)
    );

    // Salidas del divisor
    assign cociente = cociente_actual;
    assign residuo = residuo_actual[31:0];

endmodule
