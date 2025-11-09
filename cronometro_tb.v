`timescale 1ns / 1ps

/**
 * Testbench para el modulo cronometro (Corregido)
 */
module cronometro_tb;

    // Parametros del testbench
    parameter CLK_FREQ = 25_000_000; // 25MHz
    parameter CLK_PERIOD = 40;       // Periodo del reloj en ns (1 / 25MHz)

    // Señales
    reg clk;
    reg reset_timer;
    reg enable_timer;

    wire [5:0] segundos;
    wire [3:0] minutos;

    // Instanciacion del Modulo (DUT - Design Under Test)
    cronometro #(
        .CLK_FREQ(CLK_FREQ)
    ) dut (
        .clk(clk),
        .reset_timer(reset_timer),
        .enable_timer(enable_timer),
        .segundos(segundos),
        .minutos(minutos)
    );

    // 1. Generacion del reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // 20ns half-period
    end

    // 2. Generacion de estimulos (el "test")
    initial begin
        // Configurar dumpeo VCD para GTKWave
        $dumpfile("cronometro_tb.vcd");
        $dumpvars(0, cronometro_tb);

        // Estado inicial y pulso de reset
        reset_timer = 1;
        enable_timer = 0;
        #(CLK_PERIOD * 10); // Espera 10 ciclos (400ns)
        reset_timer = 0;
        #(CLK_PERIOD * 10); // Espera 10 ciclos (400ns)

        // Habilitar el contador por 62 segundos (tiempo simulado)
        $display("T=%0t: Habilitando timer...", $time);
        enable_timer = 1;
        
        // CORRECCION AQUI:
        // Espera 62 segundos. La timescale es 1ns.
        // 62 segundos = 62,000,000,000 ns
        #(62_000_000_000); 
        
        $display("T=%0t: Timer habilitado por 62s. Resultado: %d:%d", $time, minutos, segundos);

        // Deshabilitar el contador por 10 segundos
        $display("T=%0t: Deshabilitando timer...", $time);
        enable_timer = 0;
        #(10_000_000_000); // Espera 10s
        $display("T=%0t: Timer deshabilitado. Resultado: %d:%d", $time, minutos, segundos);

        // Volver a habilitar
        $display("T=%0t: Rehabilitando timer...", $time);
        enable_timer = 1;
        #(5_000_000_000); // Espera 5s
        $display("T=%0t: Timer rehabilitado por 5s. Resultado: %d:%d", $time, minutos, segundos);
        
        // Finalizar simulacion
        $display("T=%0t: Fin del test.", $time);
        $finish;
    end

endmodule
