`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Stos.
    Moduł stos implementuje strukturę danych typu stos (LIFO) o parametryzowanej głębokości i szerokości słowa. Obsługuje operacje push (włożenie danych na stos) i pop (zdjęcie danych ze stosu). Moduł sygnalizuje stany full (stos pełny) i empty (stos pusty).

    REQ_Stos:
        REQ_Stos_1:
            Moduł musi posiadać pamięć stosu stos_pamiec o rozmiarze STOS_Rozm, gdzie każde słowo ma szerokość STOS_data_rozm.
        REQ_Stos_2:
            Moduł musi posiadać wskaźnik stosu stos_ptr, który wskazuje na następną wolną pozycję w stosie.
        REQ_Stos_3:
            Po resecie (rst = 1) stos musi zostać wyzerowany (stos_pamiec, stos_ptr, full=0, empty=1).
        REQ_Stos_4:
            W przypadku aktywacji sygnału push przy nieaktywnym sygnale pop, moduł musi zapisać dane wejściowe data_in na wierzchu stosu oraz zwiększyć wskaźnik stosu o jeden.
        REQ_Stos_5:
            Po wykonaniu operacji push, stos nie może być oznaczony jako pusty, a w przypadku zapisu ostatniego dostępnego elementu musi zostać ustawiona flaga full.
        REQ_Stos_6:
            W przypadku aktywacji sygnału pop przy nieaktywnym sygnale push, moduł musi zdjąć element z wierzchu stosu poprzez zmniejszenie wskaźnika stosu o jeden.
        REQ_Stos_7:
            Po wykonaniu operacji pop, stos nie może być oznaczony jako pełny, a w przypadku usunięcia ostatniego elementu musi zostać ustawiona flaga empty.
        REQ_Stos_8:
            Podczas operacji pop, jeżeli stos nie jest pusty, moduł musi wystawić na wyjściu data_out wartość elementu znajdującego się na wierzchu stosu.


*/
//////////////////////////////////////////////////////////////////////////////////

module stos#(
        parameter STOS_data_rozm = 8,
        parameter STOS_Rozm = 32
    )(
        input wire clk,
        input wire rst,
        input wire push,
        input wire pop,
        input wire [STOS_data_rozm-1:0] data_in,
        output logic [STOS_data_rozm-1:0] data_out,
        output logic full,
        output logic empty
    );

    logic [STOS_data_rozm-1:0] stos_pamiec [STOS_Rozm-1:0];
    logic [$clog2(STOS_Rozm)-1:0] stos_ptr;

    always_ff @(posedge clk) begin : stos   //always_ff   always @( posedge clk ) begin
        if(rst) begin
            for(int i=0;i < STOS_Rozm; i++) begin
                stos_pamiec[i] <= '0;
            end
            stos_ptr <= '0;
            full <= '0;
            empty <= '1;
        end else begin

            if(push && !pop) begin
                stos_pamiec[stos_ptr] <= data_in;
                stos_ptr <= stos_ptr + 1'b1;
                empty <= '0;
                if(stos_ptr == STOS_Rozm - 1) full <= '1;
                //end
            end else if(pop && !push) begin
                stos_ptr <= stos_ptr - 1'b1;
                full <= '0;
                if(stos_ptr == 1) empty <= '1;
                //end
            end
            
        end
    end

    always_comb begin   //always_comb   always @(*) begin : blockName
        if(pop && !empty) begin
           data_out = stos_pamiec[stos_ptr - 1'b1];//1
        end else begin
           data_out = '0;
        end
    end

endmodule