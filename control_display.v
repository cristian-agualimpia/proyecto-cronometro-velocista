/**
 * Modulo Control Display 5 Digitos (M:SS:tt)
 * Ensambla la logica de conversion y multiplexado.
 * Este modulo conecta:
 * 1. bin_to_bcd_2digit (x2)
 * 2. mux_refresco_5digit (x1)
 * 3. bcd_to_7seg (x1)
 */
module control_display (
    input wire clk, // Reloj principal (25MHz)
    
    // Entradas de tiempo (del cronometro.v)
    input wire [3:0] minutos_bin,  // 0-9
    input wire [5:0] segundos_bin, // 0-59
    input wire [6:0] centesimas_bin, // 0-99
    
    // Salidas a la etapa de potencia
    output wire [6:0] segmentos_out, // Cátodos comunes
    output wire [4:0] anodos_out     // 5 Ánodos comunes
);

    // --- LOGICA INTERNA ---

    // 1. Cables para los 4 digitos BCD que necesitan conversion
    wire [3:0] bcd_seg_decenas;
    wire [3:0] bcd_seg_unidades;
    wire [3:0] bcd_cent_decenas;
    wire [3:0] bcd_cent_unidades;
    
    // (minutos_bin [3:0] ya es BCD (0-9), no necesita conversion)

    // 2. Instancias del Convertidor Binario -> BCD (Paso 2)
    
    // Convertidor para Segundos (SS)
    bin_to_bcd_2digit bin2bcd_segundos (
        .bin_in(segundos_bin), // 6 bits in (0-59)
        .bcd_decenas(bcd_seg_decenas), 
        .bcd_unidades(bcd_seg_unidades)
    );
    
    // Convertidor para Centesimas (tt)
    bin_to_bcd_2digit bin2bcd_centesimas (
        .bin_in(centesimas_bin), // 7 bits in (0-99)
        .bcd_decenas(bcd_cent_decenas), 
        .bcd_unidades(bcd_cent_unidades)
    );

    // 3. Instancia del Multiplexado (Paso 3)
    wire [3:0] bcd_mux_out; // El BCD del dígito activo
    
    mux_5digit mux (
        .clk(clk),
        .bcd_in_d4(minutos_bin),      // Digito M
        .bcd_in_d3(bcd_seg_decenas),  // Digito S
        .bcd_in_d2(bcd_seg_unidades), // Digito S
        .bcd_in_d1(bcd_cent_decenas), // Digito t
        .bcd_in_d0(bcd_cent_unidades),// Digito t
        
        .bcd_mux_out(bcd_mux_out), // BCD a mostrar
        .anodos_out(anodos_out)    // Salida a potencia
    );

    // 4. Instancia del Decodificador (Paso 1)
    bcdto7seg decoder (
        .bcd_in(bcd_mux_out),
        .segmentos_out(segmentos_out) // Salida a potencia
    );

endmodule
