
`timescale 1ns/1ps

module tb_registro_cociente32;

    logic clk = 0;
    logic reset;
    logic clear;
    logic shift;
    logic bit_in;
    logic [31:0] q;

    always #5 clk = ~clk;

    registro_cociente32 dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .shift(shift),
        .bit_in(bit_in),
        .q(q)
    );

    // Aplicar un desplazamiento y verificar resultado
    task automatic probar_shift(
        input logic nuevo_bit,
        input logic [31:0] esperado
    );
        begin
            @(negedge clk);
            shift = 1;
            bit_in = nuevo_bit;

            @(posedge clk);
            #1;

            if (q !== esperado)
                $fatal(1,
                    "Error: esperado %h, obtenido %h",
                    esperado, q
                );
        end
    endtask

    initial begin
        $dumpfile("simulaciones/registro_cociente32.vcd");
        $dumpvars(0, tb_registro_cociente32);

        reset = 1;
        clear = 0;
        shift = 0;
        bit_in = 0;

        // Reinicio inicial
        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error en reset");

        // Limpiar registro
        @(negedge clk);
        reset = 0;
        clear = 1;

        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error en clear");

        @(negedge clk);
        clear = 0;

        // Probar desplazamientos: 1, 0, 1, 1
        probar_shift(1, 1);
        probar_shift(0, 2);
        probar_shift(1, 5);
        probar_shift(1, 11);

        // Mantener el valor
        @(negedge clk);
        shift = 0;
        bit_in = 0;

        @(posedge clk);
        #1;
        if (q !== 11)
            $fatal(1, "Error al mantener");

        // Agregar un cero al cociente
        probar_shift(0, 22);

        // Comprobar prioridad de clear
        @(negedge clk);
        clear = 1;
        shift = 1;
        bit_in = 1;

        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error en prioridad clear");

        @(negedge clk);
        clear = 0;

        // Insertar 32 bits iguales a uno
        for (int i = 0; i < 32; i++) begin
            probar_shift(1, 32'hFFFFFFFF >> (31-i));
        end

        if (q !== 32'hFFFFFFFF)
            $fatal(1, "Error al llenar 32 bits");

        // Comprobar el desplazamiento de 32 bits
        probar_shift(0, 32'hFFFFFFFE);

        // Reinicio final
        @(negedge clk);
        reset = 1;
        shift = 0;

        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error en reset final");

        $display(
            "Registro cociente: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
