// Archivo: servo_pwm.v
// Descripción: Módulo generador de señal PWM para control de un servomotor.
//              Diseñado para una FPGA Colorlight V8.2 con reloj de 25 MHz.
//              Controla un servo para 0° (1ms pulso) y 90° (1.5ms pulso).

module servo_pwm (
    // Entradas
    input wire clk,             // Reloj principal de 25 MHz de la FPGA
    input wire reset,           // Señal de reset asíncrono (activo en alto)
    input wire comando_banderin, // 0 = Bajar (0 grados, 1ms), 1 = Subir (90 grados, 1.5ms)

    // Salidas
    output wire servo_pwm_out   // Salida PWM para el servomotor
);

    // --- Parámetros de Configuración (Fáciles de ajustar) ---
    // (Corregido para warnings de linter)
    parameter integer CLK_FREQ_HZ = 25_000_000; // 25 MHz

    // Periodo total del ciclo PWM para el servo (50 Hz = 20 ms)
    parameter integer SERVO_PERIOD_MS = 20;
    parameter integer SERVO_PERIOD_CLKS = (CLK_FREQ_HZ * SERVO_PERIOD_MS) / 1000; // 500_000 clks

    // Duración del pulso para 0 grados (Bajar) en ms
    parameter integer PULSE_0DEG_MS = 1.0; // Usar 'real' para números con decimales
    parameter integer PULSE_0DEG_CLKS = (CLK_FREQ_HZ * PULSE_0DEG_MS) / 1000; // 25_000 clks

    // Duración del pulso para 90 grados (Subir) en ms
    parameter real PULSE_90DEG_MS = 1.5; // Usar 'real' para números con decimales
    parameter integer PULSE_90DEG_CLKS = (CLK_FREQ_HZ * PULSE_90DEG_MS) / 1000; // 37_500 clks

    // Ancho en bits para nuestros contadores.
    parameter integer COUNTER_BITS = 19;
    // --- Bloque 1: Generador de Base de Tiempo (Contador Cíclico) ---
    reg [COUNTER_BITS-1:0] count_periodo;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_periodo <= 0;
        end else begin
            if (count_periodo == (SERVO_PERIOD_CLKS - 1)) begin
                count_periodo <= 0;
            end else begin
                count_periodo <= count_periodo + 1;
            end
        end
    end

    // --- Bloque 2: Lógica de Comando (Mapeador Combinacional) ---
    wire [COUNTER_BITS-1:0] posicion_target;

    // (LÍNEA 63 CORREGIDA)
    // Simplemente asignamos los números decimales. Verilog los ajustará
    // automáticamente al tamaño de 'posicion_target' (19 bits).
    assign posicion_target = (comando_banderin == 1'b1) ? 37500 : 25000;


    // --- Bloque 3: Lógica de Salida (Comparador Combinacional) ---
    assign servo_pwm_out = (count_periodo < posicion_target);

endmodule
