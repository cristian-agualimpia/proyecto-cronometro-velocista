module bcdto7seg (
    input wire [3:0] bcd_in,
    output reg [6:0] segmentos_out
);

    // Segmentos: {g, f, e, d, c, b, a}
    localparam S_0 = 7'b0000001; // 0
    localparam S_1 = 7'b1001111; // 1
    localparam S_2 = 7'b0010010; // 2
    localparam S_3 = 7'b0000110; // 3
    localparam S_4 = 7'b1001100; // 4
    localparam S_5 = 7'b0100100; // 5
    localparam S_6 = 7'b0100000; // 6
    localparam S_7 = 7'b0001111; // 7
    localparam S_8 = 7'b0000000; // 8
    localparam S_9 = 7'b0000100; // 9
    localparam S_OFF = 7'b1111111; // Apagado

    always @(*) begin
        case (bcd_in)
            4'd0:    segmentos_out = S_0;
            4'd1:    segmentos_out = S_1;
            4'd2:    segmentos_out = S_2;
            4'd3:    segmentos_out = S_3;
            4'd4:    segmentos_out = S_4;
            4'd5:    segmentos_out = S_5;
            4'd6:    segmentos_out = S_6;
            4'd7:    segmentos_out = S_7;
            4'd8:    segmentos_out = S_8;
            4'd9:    segmentos_out = S_9;
            default: segmentos_out = S_OFF;
        endcase
    end
endmodule
