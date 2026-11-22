
module control_divisor (
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic negativo,
    input  logic divisor_cero,

    output logic load_operands,
    output logic clear_quotient,
    output logic shift_divisor,
    output logic shift_quotient,
    output logic write_remainder,
    output logic bit_cociente,
    output logic busy,
    output logic done,
    output logic div_zero
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        RUN,
        DONE
    } state_t;

    state_t state;
    logic [5:0] contador;
    logic error_div_zero;

    // Control de estados e iteraciones
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            contador <= 6'd0;
            error_div_zero <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= LOAD;
                        error_div_zero <= 1'b0;
                    end
                end

                LOAD: begin
                    contador <= 6'd0;
                    error_div_zero <= divisor_cero;

                    if (divisor_cero)
                        state <= DONE;
                    else
                        state <= RUN;
                end

                RUN: begin
                    if (contador == 6'd32)
                        state <= DONE;
                    else
                        contador <= contador + 1'b1;
                end

                DONE: begin
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // Generacion de senales de control
    always_comb begin
        load_operands   = 1'b0;
        clear_quotient  = 1'b0;
        shift_divisor   = 1'b0;
        shift_quotient  = 1'b0;
        write_remainder = 1'b0;
        bit_cociente    = 1'b0;
        busy            = 1'b0;
        done            = 1'b0;
        div_zero        = 1'b0;

        case (state)
            IDLE: begin
            end

            LOAD: begin
                load_operands  = 1'b1;
                clear_quotient = 1'b1;
                busy = 1'b1;
            end

            RUN: begin
                busy = 1'b1;

                shift_divisor  = 1'b1;
                shift_quotient = 1'b1;

                bit_cociente = ~negativo;
                write_remainder = ~negativo;
            end

            DONE: begin
                done = 1'b1;
                div_zero = error_div_zero;
            end

            default: begin
            end
        endcase
    end

endmodule
