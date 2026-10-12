`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Rejestry.
    Moduł Rejestry implementuje bank rejestrów o liczbie Rx_liczba, gdzie każdy rejestr ma szerokość Rx_rozm_data bitów. Moduł umożliwia zapis do wybranego rejestru oraz odczyt wartości z rejestru wybranego przez numer nr_Rx.

    REQ_Rx:
        REQ_Rx_1:
            Moduł musi posiadać Rx_liczba rejestrów, każdy o szerokości Rx_rozm_data bitów.
        REQ_Rx_2:
            Podczas resetu (rst = 1) wszystkie rejestry muszą zostać wyzerowane (wartość 0).
        REQ_Rx_3:
            Jeżeli wr_Rx = 1, to podczas narastającego zbocza zegara clk wartość wejściowa dane musi zostać zapisana do rejestru o numerze nr_Rx.
        REQ_Rx_4:
            Jeżeli wr_Rx = 0, to żaden rejestr nie może zostać zmieniony.
        REQ_Rx_5:
            Odczyt rejestru musi być wykonywany asynchronicznie, a wyjście out musi zawsze odzwierciedlać aktualną zawartość rejestru rejestr[nr_Rx].

1<<ADDR_WIDTH 1 przesuniete w lewo o 8. czyli 2^8.
*/
//////////////////////////////////////////////////////////////////////////////////

module Rejestry
    #(
        parameter Rx_liczba = 8,
        parameter Rx_rozm_data = 8
    )
    (
        input wire clk,
        input wire rst,
        input wire wr_Rx,
        input wire [$clog2(Rx_liczba)-1:0] nr_Rx,//input wire [2:0] nr_Rx,
        input wire [Rx_rozm_data-1:0] dane,
        output logic [Rx_rozm_data-1:0] out
    );

    logic [Rx_rozm_data-1:0] rejestr [Rx_liczba-1:0];

    always_ff @(posedge clk) begin : always_Rx  //always_ff    always @( posedge clk )
        if(rst) begin
            for(int i=0;i<Rx_liczba;i++) begin //rejestr <= '{default:'0};
                rejestr[i] <= '0; 
            end
        end else if(wr_Rx) rejestr[nr_Rx] <= dane;
    end
    //odczyt zawsze
    assign out = rejestr[nr_Rx];

endmodule