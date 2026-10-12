`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
/*

Licznik 16bitowy. L i H po 8bit
generowanie przerwan jak przepelnienie. zlicznaie w góre
rejestr:
0- Preskaler_1 ,1- Preskaler_2 ,2- Preskaler_3 ,3- Interrupt_enable  ,4- Tryb ,5-  ,6-  ,7- Enable ,  
odczyt wartosci timea przer pooling - flaga jest generowana i poprostu if jest zrobiony
*/
///////////////////////////////////////////////////////////////////////////

module licznik(
    input wire clk,
    input wire rst,
    input wire [7:0] wartosc,
    input wire zapisz_L,
    input wire zapisz_H,
    input wire zapisz_ctr,
    output logic licznik_int,
    output logic licznik_flaga, 
    input wire licznik_flaga_clear
);

logic [15:0] wartosc_max;
logic [15:0] licznik;
logic [15:0] preskaler;
logic [15:0] preskaler_cnt;
logic int_enable;
logic tryb;
logic licznik_enable;

always_ff @(posedge clk) begin   //always  always_ff
    if(rst) begin
        licznik <= '0;
        licznik_int <= '0;
        licznik_flaga <= '0;
        preskaler_cnt <= '0;
        preskaler <= 16'd1;
        licznik_enable <= '0;
        tryb <= '0;
        int_enable <= '0;
        wartosc_max <= 16'hFFFF;
    end else begin
        licznik_int <= '0;

        //zapis
        if(zapisz_ctr) begin
            int_enable <= wartosc[3];
            tryb <= wartosc[4];
            licznik_enable <= wartosc[7];
            case(wartosc[2:0])
                3'b001: preskaler <= 16'd1; //bez
                3'b010: preskaler <= 16'd8; //8
                3'b011: preskaler <= 16'd64; //64
                3'b100: preskaler <= 16'd256;
                3'b101: preskaler <= 16'd1024;
                default: preskaler <= 16'd1; //bez
            endcase
        end else if(zapisz_L) begin
            wartosc_max[7:0] <= wartosc;
        end else if(zapisz_H) begin
            wartosc_max[15:8] <= wartosc;
        end
        //liczenie
        if(licznik_enable) begin
            //preskaler
            if(preskaler_cnt == preskaler - 1'b1) begin
                licznik <= licznik + 1'b1;
                preskaler_cnt <= '0;
            end else begin
                preskaler_cnt <= preskaler_cnt + 1'b1;
            end
            //licznik
            if(tryb) begin //tryb 1  - przerwania od max
                if(licznik == 16'hFFFF) begin
                    licznik_flaga <= '1;//flaga
                    licznik_int <= (int_enable) ? 1'b1 : 1'b0; //przerwanie
                    licznik <= '0;
                end
            end else begin // tryb 0 - przerwanie od osiagniecia ustalonego max
                if((licznik == wartosc_max - 1'b1) && (preskaler_cnt == preskaler - 1'b1)) begin
                    licznik_flaga <= '1;
                    licznik_int <= (int_enable) ? 1'b1 : 1'b0;
                    licznik <= '0;
                    preskaler_cnt <= '0;
                end
            end
            //clear
            if(licznik_flaga_clear) begin
                licznik_flaga <= '0;
            end
        end else begin
            licznik <= '0; //tutaj
            licznik_int <= '0;
            licznik_flaga <= '0;
        end
    end
end

endmodule