
`timescale 1ns/1ps

module tb_alu_divisor64;

    logic [63:0] residuo;
    logic [63:0] divisor;
    logic [63:0] diferencia;
    logic negativo;

    alu_divisor64 dut (
        .residuo(residuo),
        .divisor(divisor),
        .diferencia(diferencia),
        .negativo(negativo)
    );

    task automatic probar(
        input logic [63:0] r,
        input logic [63:0] d,
        input logic [63:0] esperado,
        input logic neg_esperado
    );
        begin
            residuo = r;
            divisor = d;
            #10;

            if (diferencia !== esperado ||
                negativo !== neg_esperado)
                $fatal(1, "Error en resta");

            $display("Prueba correcta: %0d - %0d", r, d);
        end
    endtask

    initial begin
        $dumpfile("simulaciones/alu_divisor64.vcd");
        $dumpvars(0, tb_alu_divisor64);

        // Resta positiva
        probar(13, 3, 10, 0);

        // Resta que requiere prestamo
        probar(3, 13, 64'hFFFFFFFFFFFFFFF6, 1);

        // Resta de ceros
        probar(0, 0, 0, 0);

        // Resta con valores grandes
        probar(
            64'hFFFFFFFFFFFFFFFF,
            64'd1,
            64'hFFFFFFFFFFFFFFFE,
            0
        );

        // Divisor desplazado mas de 32 bits
        probar(
            64'h0000000080000000,
            64'h0000000100000000,
            64'hFFFFFFFF80000000,
            1
        );

        $display("ALU divisor: todas las pruebas pasaron.");
        $finish;
    end

endmodule
