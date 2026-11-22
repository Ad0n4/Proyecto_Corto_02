
`timescale 1ns/1ps

module tb_control_multiplicador;

    logic clk = 0;
    logic reset = 1;
    logic start = 0;
    logic bit0 = 0;

    logic load_operands;
    logic clear_product;
    logic shift_regs;
    logic write_product;
    logic busy;
    logic done;

    always #5 clk = ~clk;

    control_multiplicador dut (
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

    initial begin
        $dumpfile("simulaciones/control_multiplicador.vcd");
        $dumpvars(0, tb_control_multiplicador);

        // Comprobar reset
        @(posedge clk);
        #1;

        if (busy !== 0 || done !== 0)
            $fatal(1, "Error en reset");

        // Iniciar multiplicacion
        @(negedge clk);
        reset = 0;
        start = 1;

        @(posedge clk);
        #1;

        if (load_operands !== 1 ||
            clear_product !== 1 ||
            busy !== 1)
            $fatal(1, "Error en LOAD");

        // Entrar al procesamiento
        @(negedge clk);
        start = 0;

        @(posedge clk);
        #1;

        if (shift_regs !== 1)
            $fatal(1, "Error al entrar en RUN");

        // Comprobar las 32 iteraciones
        for (int i = 0; i < 32; i++) begin
            @(negedge clk);
            bit0 = (i % 2 == 0);
            #1;

            if (shift_regs !== 1)
                $fatal(1, "Error en iteracion %0d", i);

            if (write_product !== bit0)
                $fatal(1, "Error en escritura %0d", i);

            @(posedge clk);
            #1;

            if (i < 31 && done !== 0)
                $fatal(1, "Finalizacion anticipada");
        end

        // Comprobar finalizacion
        if (done !== 1 || busy !== 0)
            $fatal(1, "Error en DONE");

        // DONE debe durar un ciclo
        @(posedge clk);
        #1;

        if (done !== 0 || busy !== 0)
            $fatal(1, "Error al regresar a IDLE");

        $display("Control multiplicador: todas las pruebas pasaron.");
        $finish;
    end

endmodule
