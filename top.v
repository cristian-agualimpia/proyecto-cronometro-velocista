`timescale 1ns / 1ps

/**
 * Modulo TOP - Ensamblaje Completo (Cronometro + Servo + Display + UART)
 *
 * Este es el "Ensamblador" o "Fabrica".
 * Toma los "Planos" (los otros modulos .v) y los conecta.
 *
 * *CONSIDERACION: El buzzer esta en paralelo con el LED Verde.*
 */
module top (
    // -----------------------------------------------------------------
    // --- Puertos Físicos (Definidos en .lpf) ---
    // -----------------------------------------------------------------
    
    // --- Entradas (4 pines) ---
    input  wire clk,             // Reloj 25MHz (P6)
    input  wire reset_n,         // Reset global (Activo-bajo, S1, K16)
    input  wire banderin_switch,  // Mapeado a "SET" (SW1, L15)
    input  wire sensor_meta,   // Asignar en .lpf

    // --- Salidas (18 pines) ---
    output wire led,             // Debug LED (T6)
    output wire servo_pin_out,   // Pin al servo (L1)
    
    output wire led_rojo,        // Asignar en .lpf
    output wire led_amarillo,    // Asignar en .lpf
    output wire led_verde,       // Asignar en .lpf (Controla LED Verde Y Buzzer)
    
    output wire uart_tx,         // Asignar en .lpf (Pin de transmision)
    
    output wire [6:0] display_segmentos, // Asignar en .lpf
    output wire [4:0] display_anodos     // Asignar en .lpf
);

    // -----------------------------------------------------------------
    // --- Lógica Interna y "Cables" (Wires) ---
    // -----------------------------------------------------------------

    // Inversión del Reset (Lógica de su archivo original)
    wire reset_signal;
    assign reset_signal = (reset_n == 1'b0); // reset_signal es '1' (activo-alto)

    // Cables Debounced (Filtrados)
    wire w_set_debounced;
    wire w_sensor_debounced;

    // FSM -> Cronometro
    wire w_reset_timer;
    wire w_enable_timer;
    
    // FSM -> Actuadores
    wire [2:0] w_semaforo;
    wire w_servo_comando;
    wire w_start_uart_trigger; // Pulso de 1 ciclo
    
    // EXPLICACION: Estos 'w_' son "Cables" internos.
    // Transportan los datos desde la salida del cronometro
    // hasta la entrada del display y la entrada del UART.
    wire [3:0] w_minutos_bin;
    wire [5:0] w_segundos_bin;
    wire [6:0] w_centesimas_bin;


    // -----------------------------------------------------------------
    // --- Instanciaciones de Módulos (Ensamblaje) ---
    // -----------------------------------------------------------------
    
    // --- Instancias de Debounce (Filtros de ruido) ---
    debounce #(.DEBOUNCE_MS(20)) debounce_set (
        .clk(clk), .btn_in_raw(banderin_switch), .btn_out_clean(w_set_debounced)
    );
    debounce #(.DEBOUNCE_MS(5)) debounce_sensor (
        .clk(clk), .btn_in_raw(sensor_meta), .btn_out_clean(w_sensor_debounced)
    );

    // --- 1. Instancia del CEREBRO (fsm_control) ---
    fsm_control fsm_inst (
        .clk(clk),
        .reset_global(reset_signal),
        .set_button_in(w_set_debounced),
        .sensor_meta_in(w_sensor_debounced),
        
        .reset_timer_out(w_reset_timer),
        .enable_timer_out(w_enable_timer),
        .semaforo_out(w_semaforo),
        .servo_out(w_servo_comando),
        .start_uart_tx_out(w_start_uart_trigger)
    );

    // --- 2. Instancia del CRONOMETRO ---
    // EXPLICACION: Esta es la sintaxis de "instanciacion".
    //
    // 'cronometro' (el TIPO): Es el nombre de su "plano" (su archivo cronometro.v).
    // 'crono_inst' (el NOMBRE): Es el "apodo" o nombre que ESTE ARCHIVO (top.v)
    //                          le da a esta copia especifica.
    //
    cronometro crono_inst (
        .clk(clk),
        .reset_timer(w_reset_timer),   // <- Cable desde la FSM
        .enable_timer(w_enable_timer), // <- Cable desde la FSM
        
        // EXPLICACION CONEXION:
        // .minutos(w_minutos_bin)
        // Significa: Conecta el puerto 'minutos' (de su cronometro.v)
        // al "cable" local 'w_minutos_bin'.
        .minutos(w_minutos_bin),
        .segundos(w_segundos_bin),
        .centesimas(w_centesimas_bin)
    );

    // --- 3. Instancia del DISPLAY ---
    control_display display_inst (
        .clk(clk),
        
        // EXPLICACION CONEXION:
        // .minutos_bin(w_minutos_bin)
        // Significa: Conecta el puerto 'minutos_bin' (del modulo display)
        // al mismo "cable" 'w_minutos_bin'.
        .minutos_bin(w_minutos_bin),
        .segundos_bin(w_segundos_bin),
        .centesimas_bin(w_centesimas_bin),
        
        .segmentos_out(display_segmentos),
        .anodos_out(display_anodos)
    );
    
    // --- 4. Instancia del SERVO (de su archivo original) ---
    servo_pwm u_mi_servo (
        .clk(clk),
        .reset(reset_signal),
        .comando_banderin(w_servo_comando), // <- Cable desde la FSM
        .servo_pwm_out(servo_pin_out)
    );
    
    // --- 5. Instancia del Controlador UART ---
    uart_time_tx uart_ctrl_inst (
        .clk(clk),
        .reset(reset_signal),
        .i_start_trigger(w_start_uart_trigger), // <- Cable desde la FSM
        .i_min(w_minutos_bin),                  // <- Cable desde el Cronometro
        .i_seg(w_segundos_bin),                 // <- Cable desde el Cronometro
        .i_cent(w_centesimas_bin),              // <- Cable desde el Cronometro
        .o_tx_pin(uart_tx)
    );

    // --- 6. Asignacion final de pines (salidas fisicas) ---
    assign led_rojo     = w_semaforo[0];
    assign led_amarillo = w_semaforo[1];
    assign led_verde    = w_semaforo[2]; // Controla LED Verde Y Buzzer
    
    assign led = led_verde; // LED de debug sigue al LED verde

endmodule
