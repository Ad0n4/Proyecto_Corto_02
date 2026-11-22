
`timescale 1ns/1ps

module tb_control_divisor;

    logic clk = 0;
    logic reset = 1;
    logic start = 0;
    logic negativo = 0;
    logic divisor_cero = 0;

    logic load_operands;
    logic clear_quotient;
    logic shift_divisor;
    logic shift_quotient;
    logic write_remainder;
    logic bit_cociente;
    logic busy;
    logic done;
    logic div_zero;

    always #5 clk = ~clk;

    control_divisor dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .negativo(negativo),
        .divisor_cero(divisor_cero),
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

    initial begin
        $dumpfile("simulaciones/control_divisor.vcd");
        $dumpvars(0, tb_control_divisor);

        // Comprobar reinicio
        @(posedge clk);
        #1;

        if (busy !== 0 || done !== 0)
            $fatal(1, "Error en reset");

        // Iniciar division normal
        @(negedge clk);
        reset = 0;
        start = 1;
        divisor_cero = 0;

        @(posedge clk);
        #1;

        if (load_operands !== 1 ||
            clear_quotient !== 1 ||
            busy !== 1)
            $fatal(1, "Error en LOAD");

        // Entrar al estado RUN
        @(negedge clk);
        start = 0;

        @(posedge clk);
        #1;

        if (shift_divisor !== 1 ||
            shift_quotient !== 1)
            $fatal(1, "Error al entrar en RUN");

        // Verificar 33 iteraciones
        for (int i = 0; i < 33; i++) begin
            @(negedge clk);
            negativo = (i % 2 == 0);
            #1;

            if (shift_divisor !== 1 ||
                shift_quotient !== 1)
                $fatal(1, "Error en iteracion %0d", i);

            if (write_remainder !== ~negativo ||
                bit_cociente !== ~negativo)
                $fatal(1, "Error en resta %0d", i);

            @(posedge clk);
            #1;

            if (i < 32 && done !== 0)
                $fatal(1, "Finalizacion anticipada");
        end

        // Comprobar finalizacion
        if (done !== 1 || busy !== 0 ||
            div_zero !== 0)
            $fatal(1, "Error en DONE");

        // DONE debe durar un ciclo
        @(posedge clk);
        #1;

        if (done !== 0)
            $fatal(1, "Error al regresar a IDLE");

        // Comprobar division entre cero
        @(negedge clk);
        start = 1;
        divisor_cero = 1;

        @(posedge clk);
        #1;

        if (load_operands !== 1)
            $fatal(1, "Error en LOAD divisor cero");

        @(negedge clk);
        start = 0;

        @(posedge clk);
        #1;

        if (done !== 1 || div_zero !== 1 ||
            busy !== 0)
            $fatal(1, "Error en division por cero");

        // Comprobar regreso a IDLE
        @(posedge clk);
        #1;

        if (done !== 0 || div_zero !== 0)
            $fatal(1, "Error al finalizar");

        $display(
            "Control divisor: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
