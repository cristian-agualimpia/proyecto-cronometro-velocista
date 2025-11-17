/**
 * Modulo: Convertidor Binario a BCD (2 Digitos)
 * Algoritmo "Double Dabble" optimizado para 7 bits (max 99)
 */
module bin_to_bcd_2digit (
    input wire [6:0] bin_in, // Entrada binaria (0-99)
    output reg [3:0] bcd_decenas,  // Decenas BCD
    output reg [3:0] bcd_unidades  // Unidades BCD
);

    // Registros internos para el algoritmo
    reg [3:0] bcd_tens;
    reg [3:0] bcd_ones;
    reg [6:0] shift_reg;
    integer   i;

    always @(*) begin
        // Inicializar
        bcd_tens  = 4'd0;
        bcd_ones  = 4'd0;
        shift_reg = bin_in;

        // Bucle "Double Dabble" (combinacional)
        // Se repite 7 veces (ancho de bits de entrada)
        for (i = 0; i < 7; i = i + 1) begin
            // 1. Ajustar si la columna > 4
            if (bcd_ones >= 5) begin
                bcd_ones = bcd_ones + 3;
            end
            if (bcd_tens >= 5) begin
                bcd_tens = bcd_tens + 3;
            end
            // 2. Desplazar todo a la izquierda 1 bit
            bcd_tens  = {bcd_tens[2:0], bcd_ones[3]};
            bcd_ones  = {bcd_ones[2:0], shift_reg[6]};
            shift_reg = shift_reg << 1;
        end

        // 3. Asignar salidas
        bcd_decenas  = bcd_tens;
        bcd_unidades = bcd_ones;
    end
endmodule
