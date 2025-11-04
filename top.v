// Archivo: top.v
// Módulo principal para la Colorlight V8.2
// Instancia el controlador de servo y lo conecta a los pines físicos.

// NO necesitamos incluir "cronometro.v" (el blink)
// El Makefile encontrará "servo_pwm.v" automáticamente.

module top (
    // -----------------------------------------------------------------
    // --- Puertos Físicos (se definen en el .lpf) ---
    // -----------------------------------------------------------------
    // Entrada de Reloj (25 MHz)
    input  wire clk,            // Pin P6
    // Entradas de Control (Switches/Botones)
    input  wire reset_n,        // Un botón para reset (usaremos S1, que es 'activo en bajo')
    input  wire banderin_switch,  // Un switch para subir/bajar (usaremos SW1)

    // Salidas
    output wire led,            // El LED de la placa (T6) para depuración
    output wire servo_pin_out   // El pin que irá al servo (usaremos L1)
);

    // -----------------------------------------------------------------
    // --- Lógica Interna ---
    // -----------------------------------------------------------------

    // El botón S1 de la placa (K16) es "activo en bajo" (presionado = 0).
    // Nuestro módulo de servo espera un reset "activo en alto".
    // Así que invertimos la señal del botón:
    wire reset_signal;
    assign reset_signal = (reset_n == 1'b0); // reset_signal es '1' cuando se presiona el botón

    // El switch SW1 (L15) es 'activo en alto' (ON = 1).
    // Esto se alinea perfectamente con nuestro 'comando_banderin'.
    wire comando_banderin_signal;
    assign comando_banderin_signal = banderin_switch;


    // --- Instanciación del Módulo servo_pwm ---
    // Aquí "creamos" una copia de nuestro módulo de servo.
    servo_pwm u_mi_servo (
        .clk              (clk),                   // Conecta el reloj de la placa
        .reset            (reset_signal),          // Conecta nuestra señal de reset (del botón)
        .comando_banderin (comando_banderin_signal), // Conecta nuestra señal de comando (del switch)
        .servo_pwm_out    (servo_pin_out)          // Conecta la salida al pin físico del servo
    );


    // --- Lógica de Depuración ---
    // Conectamos el LED de la placa (T6) al switch.
    // Si el switch está en 'Subir' (ON), el LED se enciende.
    // Esto te da confirmación visual inmediata de que el switch funciona.
    assign led = comando_banderin_signal;


endmodule
