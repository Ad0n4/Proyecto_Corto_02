
module multiplicador32 (
    input  logic        clk,
    input  logic        reset,
    input  logic        start,
    input  logic [31:0] a,
    input  logic [31:0] b,

    output logic [63:0] producto,
    output logic        busy,
    output logic        done
);

    // Senales internas
    logic [63:0] multiplicando_actual;
    logic [31:0] multiplicador_actual;
    logic [63:0] suma;
    logic bit0;

    logic load_operands;
    logic clear_product;
    logic shift_regs;
    logic write_product;

    // Unidad de control
    control_multiplicador u_control (
        .clk(clk),
        .reset(reset),
        .start(start),
        .bit0(bit0),
        .load_operands(load_operands),
        .clear_product(clear_product),
        .shift_regs(shift_regs),
        .write_product(write_product),
        .busy(busy),
        .done(done)
    );

    // Registro del multiplicando
    registro_multiplicando u_multiplicando (
        .clk(clk),
        .reset(reset),
        .load(load_operands),
        .shift(shift_regs),
        .data_in(a),
        .q(multiplicando_actual)
    );

    // Registro del multiplicador
    registro_multiplicador u_multiplicador (
        .clk(clk),
        .reset(reset),
        .load(load_operands),
        .shift(shift_regs),
        .data_in(b),
        .q(multiplicador_actual),
        .bit0(bit0)
    );

    // Sumador de 64 bits
    sumador64 u_sumador (
        .a(producto),
        .b(multiplicando_actual),
        .suma(suma)
    );

    // Registro del producto acumulado
    registro_producto u_producto (
        .clk(clk),
        .reset(reset),
        .clear(clear_product),
        .write_en(write_product),
        .data_in(suma),
        .q(producto)
    );

endmodule
