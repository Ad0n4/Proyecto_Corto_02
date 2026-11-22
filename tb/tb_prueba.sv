
`timescale 1ns/1ps

module tb_prueba;

    logic clk = 0;

    // Generación del reloj
    always #5 clk = ~clk;

    initial begin
        $dumpfile("simulaciones/prueba.vcd");
        $dumpvars(0, tb_prueba);

        #100;
        $finish;
    end

endmodule
