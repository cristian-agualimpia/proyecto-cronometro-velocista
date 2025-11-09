/**
 * Modulo: Controlador de Transmision de Tiempo (Corregido)
 *
 * FSM que toma el tiempo binario y envia 3 bytes usando el
 * motor 'uart_tx.v' cuando recibe el 'i_start_trigger'.
 *
 * Byte 1: {4'b0, minutos[3:0]}
 * Byte 2: {2'b0, segundos[5:0]}
 * Byte 3: {1'b0, centesimas[6:0]}
 */
module uart_time_tx (
    input wire clk,
    input wire reset,
    
    // Trigger de la FSM principal
    input wire i_start_trigger, 
    
    // Datos de tiempo (del cronometro.v)
    input wire [3:0] i_min,
    input wire [5:0] i_seg,
    input wire [6:0] i_cent,
    
    // Salida al pin fisico
    output wire o_tx_pin
);

    // --- Cables para el motor UART ---
    reg  uart_start_tx;
    reg  [7:0] uart_data_byte;
    wire uart_busy;
    
    // --- FSM de 3 estados ---
    localparam [1:0] 
        S_IDLE      = 2'd0,
        S_SEND_MIN  = 2'd1,
        S_SEND_SEG  = 2'd2,
        S_SEND_CENT = 2'd3;

    reg [1:0] state;
    
    // Registros para "congelar" (latch) el tiempo
    reg [3:0] r_min;
    reg [5:0] r_seg;
    reg [6:0] r_cent;

    // --- 1. Instancia del Motor UART (uart_tx.v) ---
    uart_tx uart_engine (
        .clk(clk),
        .reset(reset),
        .i_start_tx(uart_start_tx),
        .i_data_byte(uart_data_byte),
        .o_tx_pin(o_tx_pin),
        .o_busy(uart_busy)
    );

    // --- 2. FSM del Controlador ---
    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            uart_start_tx <= 1'b0;
        end 
        else begin
            // Por defecto, no iniciar transmision
            uart_start_tx <= 1'b0; 
            
            case(state)
                S_IDLE: 
                    if (i_start_trigger) begin
                        // Llego el pulso! Congelar el tiempo y empezar
                        r_min  <= i_min;
                        r_seg  <= i_seg;
                        r_cent <= i_cent;
                        state  <= S_SEND_MIN;
                    end
                
                // --- CORRECCION ---
                // Se agrego el 'begin...end'
                S_SEND_MIN: begin
                    uart_start_tx <= 1'b1; // Inicia envio de 1 byte
                    uart_data_byte <= {4'b0, r_min}; // Carga el byte
                    state <= S_SEND_SEG; // Pasa al siguiente estado
                end
                
                S_SEND_SEG:
                    if (!uart_busy) begin // Espera que el motor este libre
                        uart_start_tx <= 1'b1;
                        uart_data_byte <= {2'b0, r_seg};
                        state <= S_SEND_CENT;
                    end
                
                S_SEND_CENT:
                    if (!uart_busy) begin // Espera que el motor este libre
                        uart_start_tx <= 1'b1;
                        uart_data_byte <= {1'b0, r_cent};
                        state <= S_IDLE; // Vuelve al reposo
                    end
            endcase
        end
    end

endmodule
