
`timescale 1ns/1ps

module tb_registro_divisor64;

    logic clk = 0;
    logic reset;
    logic load;
    logic shift;
    logic [31:0] data_in;
    logic [63:0] q;

    always #5 clk = ~clk;

    registro_divisor64 dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .q(q)
    );

    initial begin
        $dumpfile("simulaciones/registro_divisor64.vcd");
        $dumpvars(0, tb_registro_divisor64);

        reset = 1;
        load = 0;
        shift = 0;
        data_in = 0;

        // Reiniciar registro
        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error en reset");

        // Cargar divisor = 3
        @(negedge clk);
        reset = 0;
        load = 1;
        data_in = 3;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000300000000)
            $fatal(1, "Error al cargar divisor");

        // Primer desplazamiento
        @(negedge clk);
        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000180000000)
            $fatal(1, "Error en shift 1");

        // Segundo desplazamiento
        @(posedge clk);
        #1;
        if (q !== 64'h00000000C0000000)
            $fatal(1, "Error en shift 2");

        // Tercer desplazamiento
        @(posedge clk);
        #1;
        if (q !== 64'h0000000060000000)
            $fatal(1, "Error en shift 3");

        // Mantener valor
        @(negedge clk);
        shift = 0;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000060000000)
            $fatal(1, "Error al mantener");

        // Comprobar valor de 32 bits
        @(negedge clk);
        load = 1;
        data_in = 32'h80000000;

        @(posedge clk);
        #1;
        if (q !== 64'h8000000000000000)
            $fatal(1, "Error en carga de 32 bits");

        // Desplazar valor grande
        @(negedge clk);
        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 64'h4000000000000000)
            $fatal(1, "Error en shift de 64 bits");

        $display(
            "Registro divisor: todas las pruebas pasaron."
        );

        $finish;
    end

endmodule
