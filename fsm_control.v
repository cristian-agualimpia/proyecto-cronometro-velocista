/**
 * Modulo: Maquina de Estados Finita (FSM) del Cronometraje (Actualizado)
 *
 * *NUEVA CONSIDERACION: El buzzer esta en paralelo con el LED Verde.*
 * Se elimina la salida 'buzzer_out'.
 */
module fsm_control #(
    parameter CLK_FREQ = 25_000_000,
    parameter COUNT_READY = CLK_FREQ * 2,// 2 segundos
    parameter COUNT_SET   = CLK_FREQ * 2,// 2 segundos
    parameter COUNT_GO    = CLK_FREQ * 1// 1 segundo
) (
    input wire clk,
    input wire reset_global,
    input wire set_button_in,
    input wire sensor_meta_in,
    // Salidas al cronometro.v
    output reg reset_timer_out,
    output reg enable_timer_out,
    // Salidas a los actuadores
    output reg [2:0] semaforo_out, // {Verde, Amarillo, Rojo}
    // 'buzzer_out' ELIMINADO
    output reg servo_out,
    output reg start_uart_tx_out
);

    // --- 1. Definicion de Estados ---
    parameter [2:0]
        S_IDLE   = 3'd0,
        S_READY  = 3'd1,
        S_SET    = 3'd2,
        S_GO     = 3'd3,
        S_TIMING = 3'd4,
        S_FINISH = 3'd5;

    reg [2:0] state, next_state;

    // (El resto del codigo: Detector de Flanco, Timer Local... es identico)
    // ... (Detector de Flanco) ...
    // ... (Timer Local) ...
    // ... (Logica de Transicion de Estado) ...
    // (Ahorro espacio omitiendo las partes no modificadas)

    // --- 5. Logica de Salida (Combinacional) ---
    always @(*) begin
        // Valores por defecto (seguros)
        reset_timer_out   = 1'b0;
        enable_timer_out  = 1'b0;
        semaforo_out      = 3'b000; // {V, A, R} -> Apagados
        // buzzer_out ELIMINADO
        servo_out         = 1'b0;
        start_uart_tx_out = 1'b0;

        case(state)
            S_IDLE: begin
                reset_timer_out = 1'b1;
            end
            S_READY: begin
                semaforo_out = 3'b001; // Rojo
            end
            S_SET: begin
                semaforo_out = 3'b010; // Amarillo
            end
            S_GO: begin
                enable_timer_out = 1'b1;
                semaforo_out     = 3'b100; // Verde (y Buzzer)
                servo_out        = 1'b1;
            end
            S_TIMING: begin
                enable_timer_out = 1'b1;
            end
            S_FINISH: begin
                enable_timer_out  = 1'b0;
                start_uart_tx_out = 1'b1;
            end
            default enable_timer_out = 0;
        endcase
    end
    // ... (Registro de Estado) ...
endmodule
