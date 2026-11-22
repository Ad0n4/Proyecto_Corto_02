
`timescale 1ns/1ps

module tb_divisor32;

    logic clk = 0;
    logic reset = 1;
    logic start = 0;

    logic [31:0] dividendo = 0;
    logic [31:0] divisor = 0;

    logic [31:0] cociente;
    logic [31:0] residuo;
    logic busy;
    logic done;
    logic div_zero;

    always #5 clk = ~clk;

    divisor32 dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .dividendo(dividendo),
        .divisor(divisor),
        .cociente(cociente),
        .residuo(residuo),
        .busy(busy),
        .done(done),
        .div_zero(div_zero)
    );

    task automatic probar(
        input logic [31:0] x,
        input logic [31:0] y
    );
        logic [31:0] cociente_esperado;
        logic [31:0] residuo_esperado;
        integer ciclos;

        begin
            // Modelo de referencia independiente
            if (y == 0) begin
                cociente_esperado = 0;
                residuo_esperado = x;
            end
            else begin
                cociente_esperado = x / y;
                residuo_esperado = x % y;
            end

            // Iniciar division
            @(negedge clk);
            dividendo = x;
            divisor = y;
            start = 1;

            @(posedge clk);
            #1;

            if (busy !== 1 || done !== 0)
                $fatal(1, "Error al iniciar");

            // Cargar operandos
            @(negedge clk);
            start = 0;

            @(posedge clk);
            #1;

            // Cambiar las entradas para comprobar
            // que los operandos quedaron registrados
            dividendo = 32'hA5A5A5A5;
            divisor = 32'h55AA55AA;

            ciclos = 0;

            if (y != 0) begin

                if (busy !== 1 || done !== 0)
                    $fatal(1, "Error al entrar en RUN");

                // Esperar las 33 iteraciones
                while (done !== 1'b1 && ciclos < 34) begin
                    @(posedge clk);
                    #1;
                    ciclos = ciclos + 1;
                end

                if (ciclos != 33)
                    $fatal(1,
                        "Error: ciclos = %0d",
                        ciclos
                    );
            end

            // Verificar finalizacion
            if (done !== 1 || busy !== 0)
                $fatal(1, "Error en DONE");

            if (div_zero !== (y == 0))
                $fatal(1, "Error en div_zero");

            // Verificar resultados
            if (cociente !== cociente_esperado ||
                residuo !== residuo_esperado)
                $fatal(1,
                    "ERROR: %0d / %0d, esperado Q=%0d R=%0d, obtenido Q=%0d R=%0d",
                    x, y,
                    cociente_esperado,
                    residuo_esperado,
                    cociente,
                    residuo
                );

            $display(
                "OK: %0d / %0d = %0d, residuo = %0d, ciclos = %0d",
                x, y, cociente, residuo, ciclos
            );

            // Comprobar que DONE dura un ciclo
            @(posedge clk);
            #1;

            if (done !== 0 || div_zero !== 0)
                $fatal(1, "Error al regresar a IDLE");
        end
    endtask

    initial begin
        $dumpfile("simulaciones/divisor32.vcd");
        $dumpvars(0, tb_divisor32);

        // Reset inicial
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Casos de prueba
        probar(13, 3);
        probar(100, 10);
        probar(0, 7);
        probar(7, 9);
        probar(32'hFFFFFFFF, 1);
        probar(32'hFFFFFFFF, 32'hFFFFFFFF);
        probar(32'hFFFFFFFF, 2);
        probar(32'h80000000, 3);
        probar(25, 0);

        // Pruebas adicionales de casos limite
        probar(1, 1);
        probar(1, 32'hFFFFFFFF);
        probar(32'h80000000, 32'h80000000);
        probar(32'h80000000, 32'hFFFFFFFF);
        probar(32'hFFFFFFFF, 32'h80000000);
        probar(32'hFFFFFFFF, 32'hFFFFFFFE);
        probar(0, 0);
        probar(65535, 255);

        // Pruebas con operandos aleatorios
        for (int i = 0; i < 20; i++) begin
            probar($urandom, $urandom);
        end


        $display(
            "Divisor completo: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
