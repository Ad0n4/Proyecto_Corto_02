
`timescale 1ns/1ps

module tb_sumador64;

    logic [63:0] a;
    logic [63:0] b;
    logic [63:0] suma;

    sumador64 dut (
        .a(a),
        .b(b),
        .suma(suma)
    );

    initial begin

        $dumpfile("simulaciones/sumador64.vcd");
        $dumpvars(0, tb_sumador64);

        // Prueba 1
        a = 13;
        b = 26;
        #10;

        if (suma !== 39)
            $fatal(1, "Error en prueba 1");

        // Prueba 2
        a = 100;
        b = 200;
        #10;

        if (suma !== 300)
            $fatal(1, "Error en prueba 2");

        // Prueba 3: suma de 64 bits
        a = 64'h0000000100000000;
        b = 5;
        #10;

        if (suma !== 64'h0000000100000005)
            $fatal(1, "Error en prueba 3");

        $display("Todas las pruebas pasaron.");

        $finish;

    end

endmodule
