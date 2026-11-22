
`timescale 1ns/1ps

module tb_multiplicador32;

    logic clk = 0;
    logic reset = 1;
    logic start = 0;

    logic [31:0] a = 0;
    logic [31:0] b = 0;

    logic [63:0] producto;
    logic busy;
    logic done;

    always #5 clk = ~clk;

    multiplicador32 dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .producto(producto),
        .busy(busy),
        .done(done)
    );

    // Prueba independiente del resultado matematico
    task automatic probar(
        input logic [31:0] x,
        input logic [31:0] y
    );
        logic [63:0] esperado;
        integer ciclos;

        begin
            esperado = {32'd0, x} * {32'd0, y};

            // Iniciar nueva multiplicacion
            @(negedge clk);
            a = x;
            b = y;
            start = 1;

            @(posedge clk);
            #1;

            if (busy !== 1 || done !== 0)
                $fatal(1, "Error al iniciar");

            @(negedge clk);
            start = 0;

            // Esperar la carga de los operandos
            @(posedge clk);
            #1;

            // Cambiar entradas para verificar
            // que los operandos quedaron registrados
            a = 0;
            b = 0;

            ciclos = 0;

            // Esperar finalizacion
            while (done !== 1'b1 && ciclos < 40) begin
                @(posedge clk);
                #1;
                ciclos = ciclos + 1;
            end

            if (done !== 1)
                $fatal(1, "Timeout de multiplicacion");

            if (ciclos != 32)
                $fatal(1, "Cantidad incorrecta de ciclos");

            if (producto !== esperado)
                $fatal(1,
                    "Error: %0d x %0d, esperado %0d, obtenido %0d",
                    x, y, esperado, producto
                );

            $display(
                "OK: %0d x %0d = %0d, ciclos = %0d",
                x, y, producto, ciclos
            );

            // Verificar que done dure un ciclo
            @(posedge clk);
            #1;

            if (done !== 0)
                $fatal(1, "done no regreso a cero");
        end
    endtask

    initial begin
        $dumpfile("simulaciones/multiplicador32.vcd");
        $dumpvars(0, tb_multiplicador32);

        // Reset inicial
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Casos de prueba
        probar(13, 3);
        probar(7, 9);
        probar(0, 123);
        probar(1, 32'hFFFFFFFF);
        probar(123456, 654321);
        probar(32'hFFFFFFFF, 32'hFFFFFFFF);

        $display(
            "Multiplicador completo: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
