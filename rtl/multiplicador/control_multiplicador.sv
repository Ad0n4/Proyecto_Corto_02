
module control_multiplicador (
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic bit0,

    output logic load_operands,
    output logic clear_product,
    output logic shift_regs,
    output logic write_product,
    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        RUN,
        DONE
    } state_t;

    state_t state;
    logic [5:0] contador;

    // Registro de estado y contador
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            contador <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start)
                        state <= LOAD;
                end

                LOAD: begin
                    contador <= 0;
                    state <= RUN;
                end

                RUN: begin
                    if (contador == 6'd31)
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

    // Señales de control
    always_comb begin
        load_operands = 0;
        clear_product = 0;
        shift_regs = 0;
        write_product = 0;
        busy = 0;
        done = 0;

        case (state)
            IDLE: begin
                // Esperar start
            end

            LOAD: begin
                load_operands = 1;
                clear_product = 1;
                busy = 1;
            end

            RUN: begin
                shift_regs = 1;
                write_product = bit0;
                busy = 1;
            end

            DONE: begin
                done = 1;
            end

            default: begin
            end
        endcase
    end

endmodule
