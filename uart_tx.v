/**
 * Modulo: Transmisor UART (Motor de 1 Byte)
 *
 * Envia 1 byte de datos (8-N-1) a un baud rate especifico.
 * Se activa con un pulso de 1 ciclo en 'i_start_tx'.
 */
module uart_tx #(
    parameter CLK_FREQ = 25_000_000,
    parameter BAUD_RATE = 115200,
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
) (
    input wire clk,
    input wire reset,
    
    input wire       i_start_tx,    // Pulso de 1 ciclo para iniciar
    input wire [7:0] i_data_byte,   // Byte a enviar
    
    output reg o_tx_pin,      // Pin de transmision (linea serial)
    output reg o_busy         // '1' mientras esta transmitiendo
);

    localparam [3:0] 
        S_IDLE  = 4'd0,
        S_START = 4'd1,
        S_DATA  = 4'd2,
        S_STOP  = 4'd3;

    reg [3:0]  state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;
    reg [3:0]  bit_cnt; // 0 (start) + 8 (data) + 1 (stop)
    reg [9:0]  tx_buffer; // {1'b1 (stop), i_data_byte[7:0], 1'b0 (start)}

    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            o_busy <= 1'b0;
            o_tx_pin <= 1'b1; // Linea en reposo
            clk_cnt <= 0;
            bit_cnt <= 0;
        end 
        else begin
            case(state)
                S_IDLE: begin
                    o_tx_pin <= 1'b1;
                    o_busy   <= 1'b0;
                    if (i_start_tx) begin
                        o_busy    <= 1'b1;
                        tx_buffer <= {1'b1, i_data_byte, 1'b0}; // Carga buffer
                        clk_cnt   <= 0;
                        bit_cnt   <= 0;
                        state     <= S_START;
                    end
                end
                
                S_START: begin
                    o_tx_pin <= tx_buffer[0]; // Envia Start Bit (0)
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        bit_cnt <= bit_cnt + 1'b1;
                        state   <= S_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                S_DATA: begin
                    o_tx_pin <= tx_buffer[bit_cnt]; // Envia data bit
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        bit_cnt <= bit_cnt + 1'b1;
                        if (bit_cnt == 9) begin // 8 bits de datos enviados
                            state <= S_STOP;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                S_STOP: begin
                    o_tx_pin <= tx_buffer[9]; // Envia Stop Bit (1)
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= S_IDLE; // Transmision completa
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
