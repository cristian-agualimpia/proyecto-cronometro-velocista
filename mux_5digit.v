/**
 * Modulo: Multiplexor de Refresco (5 Digitos) - M:SS:tt
 * Frecuencia de Refresco por Digito: 25MHz / 50,000 = 500 Hz
 */
module mux_5digit (
    input wire clk, // Reloj principal (25MHz)
    // Entradas BCD de los 5 digitos
    input wire [3:0] bcd_in_d4, // M (Minutos)
    input wire [3:0] bcd_in_d3, // S (Segundos Decenas)
    input wire [3:0] bcd_in_d2, // S (Segundos Unidades)
    input wire [3:0] bcd_in_d1, // t (Centesimas Decenas)
    input wire [3:0] bcd_in_d0, // t (Centesimas Unidades)
    // Salidas
    output reg [3:0] bcd_mux_out, // BCD del digito activo
    output reg [4:0] anodos_out   // Control de potencia (anodo activo)
);

    parameter integer REFRESH_COUNT = 50_000; // 25MHz / 50k = 500Hz
    reg [$clog2(REFRESH_COUNT)-1:0] refresh_cnt;
    reg [2:0] digit_sel; // Contador para 5 digitos (0-4)

    always @(posedge clk) begin
        // 1. Divisor de frecuencia para el refresco
        if (refresh_cnt == REFRESH_COUNT - 1) begin
            refresh_cnt <= 0;
            // 2. Cambiar al siguiente digito
            if (digit_sel == 4) begin
                digit_sel <= 0;
            end else begin
                digit_sel <= digit_sel + 1'b1;
            end
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
        end
    end

    // 3. Logica del MUX (Combinacional)
    always @(*) begin
        case (digit_sel)
            3'd0: begin // Digito 0 (Centesimas Unidades)
                bcd_mux_out = bcd_in_d0;
                anodos_out  = 5'b00001;
            end
            3'd1: begin // Digito 1 (Centesimas Decenas)
                bcd_mux_out = bcd_in_d1;
                anodos_out  = 5'b00010;
            end
            3'd2: begin // Digito 2 (Segundos Unidades)
                bcd_mux_out = bcd_in_d2;
                anodos_out  = 5'b00100;
            end
            3'd3: begin // Digito 3 (Segundos Decenas)
                bcd_mux_out = bcd_in_d3;
                anodos_out  = 5'b01000;
            end
            3'd4: begin // Digito 4 (Minutos)
                bcd_mux_out = bcd_in_d4;
                anodos_out  = 5'b10000;
            end
            default: begin
                bcd_mux_out = 4'hF;     // Apagado
                anodos_out  = 5'b00000; // Ningun anodo
            end
        endcase
    end
endmodule
