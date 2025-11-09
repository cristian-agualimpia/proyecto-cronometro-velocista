/**
 * Modulo: Debouncer de Boton (Filtro de Ruido)
 *
 * Espera que una señal de entrada sea estable por un periodo
 * (DEBOUNCE_TIME) antes de cambiar la salida.
 *
 * Basado en un reloj de 25MHz.
 * 20ms = 500,000 ciclos.
 */
module debounce #(
    parameter CLK_FREQ = 25_000_000,
    parameter DEBOUNCE_MS = 20, // 20ms de filtro
    parameter COUNT_MAX = (CLK_FREQ / 1000) * DEBOUNCE_MS
) (
    input wire clk,
    input wire btn_in_raw,  // Entrada fisica (ruidosa)
    output reg btn_out_clean // Salida limpia
);

    // Sincronizador de 2 etapas para la entrada
    reg s1, s2;
    always @(posedge clk) begin
        s1 <= btn_in_raw;
        s2 <= s1;
    end
    
    reg [$clog2(COUNT_MAX)-1:0] debounce_cnt;

    always @(posedge clk) begin
        if (s2 != btn_out_clean) begin
            // La entrada (sincronizada) no coincide con la salida
            if (debounce_cnt == COUNT_MAX - 1) begin
                // El contador llego al maximo, la señal es estable
                btn_out_clean <= s2; // Acepta el nuevo valor
                debounce_cnt <= 0;
            end else begin
                // Sigue contando
                debounce_cnt <= debounce_cnt + 1'b1;
            end
        end else begin
            // La entrada y la salida coinciden, resetea el contador
            debounce_cnt <= 0;
        end
    end

endmodule
