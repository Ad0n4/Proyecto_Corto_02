
`timescale 1ns/1ps

module tb_registro_producto;

    logic clk = 0;
    logic reset;
    logic clear;
    logic write_en;
    logic [63:0] data_in;
    logic [63:0] q;

    always #5 clk = ~clk;

    registro_producto dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .write_en(write_en),
        .data_in(data_in),
        .q(q)
    );

    initial begin
        $dumpfile("simulaciones/registro_producto.vcd");
        $dumpvars(0, tb_registro_producto);

        reset = 1;
        clear = 0;
        write_en = 0;
        data_in = 0;

        // Reiniciar registro
        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error en reset");

        // Guardar primer producto parcial
        @(negedge clk);
        reset = 0;
        write_en = 1;
        data_in = 13;

        @(posedge clk);
        #1;
        if (q !== 64'd13)
            $fatal(1, "Error al guardar 13");

        // Guardar suma acumulada
        @(negedge clk);
        data_in = 39;

        @(posedge clk);
        #1;
        if (q !== 64'd39)
            $fatal(1, "Error al guardar 39");

        // Mantener resultado
        @(negedge clk);
        write_en = 0;
        data_in = 100;

        @(posedge clk);
        #1;
        if (q !== 64'd39)
            $fatal(1, "Error al mantener valor");

        // Limpiar registro
        @(negedge clk);
        clear = 1;
        write_en = 1;
        data_in = 999;

        @(posedge clk);
        #1;
        if (q !== 64'd0)
            $fatal(1, "Error al limpiar registro");

        // Comprobar almacenamiento de 64 bits
        @(negedge clk);
        clear = 0;
        write_en = 1;
        data_in = 64'h0000000100000000;

        @(posedge clk);
        #1;
        if (q !== 64'h0000000100000000)
            $fatal(1, "Error con datos de 64 bits");

        $display("Registro producto: todas las pruebas pasaron.");
        $finish;
    end

endmodule
