// Archivo: servo_pwm_tb.v
// Testbench para el módulo servo_pwm

`timescale 1ns / 1ps // Define las unidades de tiempo para la simulación

module servo_pwm_tb;

    // --- Parámetros de Configuración (COPIADOS DE servo_pwm.v) ---
    // ¡El testbench necesita saber estos valores para los delays!
    localparam integer CLK_FREQ_HZ = 25_000_000;
    localparam integer SERVO_PERIOD_MS = 20;
    localparam integer SERVO_PERIOD_CLKS = (CLK_FREQ_HZ * SERVO_PERIOD_MS) / 1000; // 500_000
    localparam integer CLK_PERIOD_NS = 40; // 1 / 25MHz = 40 ns
    localparam integer CLK_HALF_PERIOD = CLK_PERIOD_NS / 2; // 20 ns

    // --- Señales de Testbench (internas al testbench) ---
    reg clk;
    reg reset;
    reg comando_banderin;
    wire servo_pwm_out;

    // --- Instanciación del DUT (nuestro módulo servo_pwm) ---
    servo_pwm dut (
        .clk(clk),
        .reset(reset),
        .comando_banderin(comando_banderin),
        .servo_pwm_out(servo_pwm_out)
    );

    // --- Generación del Reloj (clk) ---
    always begin
        clk = 0;
        #(CLK_HALF_PERIOD) clk = 1;
        #(CLK_HALF_PERIOD) ; 
    end

    // --- Generación de Estímulos de Prueba ---
    initial begin
        // 1. Inicializar todas las entradas
        clk = 0;
        reset = 1; // Mantener reset activo al inicio
        comando_banderin = 0; 

        // 2. Aplicar reset y luego liberarlo
        #100; // Esperar 100 ns
        reset = 0; // Liberar reset
        
        // Esperar 2 ciclos de servo (2 * 20ms)
        // 20ms = 20,000,000 ns
        #(2 * 20_000_000); 

        // 3. Probar el comando para bajar el banderín (ya está en 0)
        $display("Tiempo: %0t ns, Comando: Bajar (0)", $time);
        #(2 * 20_000_000); // Esperar 2 ciclos de servo

        // 4. Probar el comando para subir el banderín (1.5ms pulso)
        $display("Tiempo: %0t ns, Comando: Subir (1)", $time);
        comando_banderin = 1;
        #(2 * 20_000_000); // Esperar 2 ciclos de servo

        // 5. Volver a bajar el banderín
        $display("Tiempo: %0t ns, Comando: Volver a Bajar (0)", $time);
        comando_banderin = 0;
        #(2 * 20_000_000); // Esperar 2 ciclos de servo

        // 6. Terminar la simulación
        $display("Tiempo: %0t ns, Simulación terminada.", $time);
        $finish;
    end

    // Opcional: Dump de señales para visualización con GTKWave
    initial begin
        $dumpfile("servo_pwm.vcd"); // Archivo donde se guardan las señales
        $dumpvars(0, servo_pwm_tb); // Guarda todas las señales del testbench
    end

endmodule
