
`timescale 1ns/1ps

module tb_registro_multiplicador;

    logic clk = 0;
    logic reset;
    logic load;
    logic shift;
    logic [31:0] data_in;
    logic [31:0] q;
    logic bit0;

    always #5 clk = ~clk;

    registro_multiplicador dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .q(q),
        .bit0(bit0)
    );

    initial begin
        $dumpfile("simulaciones/registro_multiplicador.vcd");
        $dumpvars(0, tb_registro_multiplicador);

        reset = 1;
        load = 0;
        shift = 0;
        data_in = 0;

        // Reiniciar
        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error en reset");

        // Cargar 13
        reset = 0;
        load = 1;
        data_in = 13;

        @(posedge clk);
        #1;
        if (q !== 13 || bit0 !== 1)
            $fatal(1, "Error al cargar");

        // Primer desplazamiento: 13 -> 6
        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 6 || bit0 !== 0)
            $fatal(1, "Error en shift 1");

        // Segundo desplazamiento: 6 -> 3
        @(posedge clk);
        #1;
        if (q !== 3 || bit0 !== 1)
            $fatal(1, "Error en shift 2");

        // Tercer desplazamiento: 3 -> 1
        @(posedge clk);
        #1;
        if (q !== 1 || bit0 !== 1)
            $fatal(1, "Error en shift 3");

        // Cuarto desplazamiento: 1 -> 0
        @(posedge clk);
        #1;
        if (q !== 0 || bit0 !== 0)
            $fatal(1, "Error en shift 4");

        // Mantener el valor
        shift = 0;

        @(posedge clk);
        #1;
        if (q !== 0)
            $fatal(1, "Error al mantener");

        // Comprobar desplazamiento sin signo
        load = 1;
        data_in = 32'h80000001;

        @(posedge clk);
        #1;
        if (q !== 32'h80000001)
            $fatal(1, "Error al cargar 32 bits");

        load = 0;
        shift = 1;

        @(posedge clk);
        #1;
        if (q !== 32'h40000000)
            $fatal(1, "Error en shift de 32 bits");

        $display("Registro multiplicador: todas las pruebas pasaron.");
        $finish;
    end

endmodule
