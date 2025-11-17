`timescale 1ns / 1ps

module cronometro #(
    parameter integer CLK_FREQ = 25_000_000, // Frecuencia del reloj (25MHz)
    parameter integer CLK_FREQ_CENT = CLK_FREQ / 100
) (
    input wire clk,
    input wire reset_timer,
    input wire enable_timer, // Reloj principal de la FPGA,
    output reg [5:0] segundos,  // sañida de segundos (0-4)
    output reg [3:0] minutos, // Salida de segundos (0-63)
    output reg [6:0] centesimas
);

    // Registro para el pre-escalador (divisor de frecuencia)
    // Necesita contar de 0 a (CLK_FREQ - 1)
    // reg [$clog2(CLK_FREQ)-1:0] preset_cnt;
    reg [$clog2(CLK_FREQ_CENT)-1:0] preset_cnt_cent;

    // Logica principal del contador
always @(posedge clk) begin
        if (reset_timer) begin
            // Resetea todos los contadores
            preset_cnt_cent <= 0;
            segundos        <= 0;
            minutos         <= 0;
            centesimas      <= 0;
        end
        else if (enable_timer) begin
            // 1. Comprobar si ha pasado 0.01s
            if (preset_cnt_cent == CLK_FREQ_CENT - 1) begin
                preset_cnt_cent <= 0;

                // 2. INICIO DE LOGICA ANIDADA CORRECTA
                if (centesimas == 99) begin
                    centesimas <= 0;
                    // 3. ANIDADO: Solo chequear segundos CUANDO centesimas se desborda
                    if (segundos == 59) begin
                        segundos <= 0;
                        if (minutos != 9) begin // Limite 9 minutos
                            minutos <= minutos + 1'b1;
                        end
                    end
                    else begin
                        segundos <= segundos + 1'b1;
                    end
                end
                else begin
                    centesimas <= centesimas + 1'b1;
                end
                // --- FIN DE LOGICA ANIDADA CORRECTA ---
            end
            else begin
                // 4. Incrementar pre-escalador
                preset_cnt_cent <= preset_cnt_cent + 1'b1;
            end
        end
    end
endmodule
