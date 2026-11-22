
`timescale 1ns/1ps

module tb_registro_multiplicando;

    logic clk = 0;
    logic reset;
    logic load;
    logic shift;
    logic [31:0] data_in;
    logic [63:0] q;

    always #5 clk = ~clk;

    registro_multiplicando dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .q(q)
    );

    initial begin
        $dumpfile("simulaciones/registro_multiplicando.vcd");
        $dumpvars(0, tb_registro_multiplicando);

        reset = 1;
        load = 0;
        shift = 0;
        data_in = 0;

        // Reinicio
        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error en reset");

        // Cargar multiplicando
        reset = 0;
        load = 1;
        data_in = 13;

        @(posedge clk);
        #1;
        if (q !== 64'd13)
            $fatal(1, "Error al cargar");

        // Primer desplazamiento
        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 64'd26)
            $fatal(1, "Error en shift 1");

        // Segundo desplazamiento
        @(posedge clk);
        #1;
        if (q !== 64'd52)
            $fatal(1, "Error en shift 2");

        // Tercer desplazamiento
        @(posedge clk);
        #1;
        if (q !== 64'd104)
            $fatal(1, "Error en shift 3");

        // Mantener valor
        shift = 0;

        @(posedge clk);
        #1;
        if (q !== 64'd104)
            $fatal(1, "Error al mantener");

        // Comprobar desplazamiento de 64 bits
        load = 1;
        data_in = 32'h80000000;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000080000000)
            $fatal(1, "Error al cargar 32 bits");

        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000100000000)
            $fatal(1, "Error en desplazamiento de 64 bits");

        $display("Registro multiplicando: todas las pruebas pasaron.");
        $finish;
    end

endmodule
