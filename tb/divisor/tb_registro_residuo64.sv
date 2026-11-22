
`timescale 1ns/1ps

module tb_registro_residuo64;

    logic clk = 0;
    logic reset;
    logic load;
    logic write_en;
    logic [31:0] dividendo_in;
    logic [63:0] data_in;
    logic [63:0] q;

    always #5 clk = ~clk;

    registro_residuo64 dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .write_en(write_en),
        .dividendo_in(dividendo_in),
        .data_in(data_in),
        .q(q)
    );

    initial begin
        $dumpfile("simulaciones/registro_residuo64.vcd");
        $dumpvars(0, tb_registro_residuo64);

        reset = 1;
        load = 0;
        write_en = 0;
        dividendo_in = 0;
        data_in = 0;

        // Prueba 1: reinicio
        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error en reset");

        // Prueba 2: cargar dividendo = 13
        @(negedge clk);
        reset = 0;
        load = 1;
        dividendo_in = 13;

        @(posedge clk);
        #1;
        if (q !== 64'd13)
            $fatal(1, "Error al cargar dividendo");

        // Prueba 3: guardar resta valida (13 - 12)
        @(negedge clk);
        load = 0;
        write_en = 1;
        data_in = 1;

        @(posedge clk);
        #1;
        if (q !== 64'd1)
            $fatal(1, "Error al guardar residuo");

        // Prueba 4: mantener residuo
        // cuando la resta no es valida
        @(negedge clk);
        write_en = 0;
        data_in = 64'hFFFFFFFFFFFFFFFB;

        @(posedge clk);
        #1;
        if (q !== 64'd1)
            $fatal(1, "Error al mantener residuo");

        // Prueba 5: almacenar 64 bits
        @(negedge clk);
        write_en = 1;
        data_in = 64'h0000000100000005;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000100000005)
            $fatal(1, "Error al almacenar 64 bits");

        // Prueba 6: cargar nuevo dividendo
        @(negedge clk);
        load = 1;
        dividendo_in = 100;

        @(posedge clk);
        #1;
        if (q !== 64'd100)
            $fatal(1, "Error al cargar nuevo dividendo");

        // Prueba 7: reset
        @(negedge clk);
        reset = 1;
        load = 0;
        write_en = 0;

        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error en reset final");

        $display(
            "Registro residuo: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
