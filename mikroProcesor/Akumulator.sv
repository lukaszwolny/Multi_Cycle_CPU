`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Akumulator.
    Moduł Akumulator realizuje rejestr akumulatora procesora, służący do przechowywania wyników operacji arytmetyczno-logicznych oraz danych pośrednich wykorzystywanych w trakcie wykonywania instrukcji. Zawartość akumulatora może być aktualizowana synchronicznie z zegarem na podstawie sygnału sterującego oraz zerowana asynchronicznie względem logiki wykonawczej poprzez sygnał resetu. Aktualna wartość akumulatora jest stale dostępna na wyjściu modułu.

    REQ_ACC:  
      REQ_ACC_1:
        Moduł musi realizować rejestr danych o szerokości określonej parametrem ALU_rozm_data.
      REQ_ACC_2:
        Po aktywacji sygnału reset (rst) zawartość akumulatora musi zostać wyzerowana w jednym cyklu zegarowym.
      REQ_ACC_3:
        Jeżeli sygnał zapisu akumulatora (A_ce) jest aktywny, moduł musi zapisać wartość z wejścia a do akumulatora przy narastającym zboczu sygnału clk.
      REQ_ACC_4:
        Jeżeli sygnał A_ce jest nieaktywny, zawartość akumulatora musi pozostać niezmieniona.
      REQ_ACC_5:
        Aktualna zawartość akumulatora musi być stale dostępna na wyjściu out.
      REQ_ACC_6:
        Wszystkie operacje zapisu oraz resetowania akumulatora muszą być realizowane synchronicznie z narastającym zboczem sygnału zegarowego clk.

*/
//////////////////////////////////////////////////////////////////////////////////

module Akumulator#(
        parameter ALU_rozm_data = 8
    )(
        input wire clk,
        input wire rst,
        input wire [ALU_rozm_data-1:0] a,
        input wire A_ce,
        output logic [ALU_rozm_data-1:0] out
    );

    logic [ALU_rozm_data-1:0] akum;

    always_ff @( posedge clk ) begin : always_A  //always_ff   always @( posedge clk ) begin
        if(rst) akum <= '0;
        else if(A_ce) akum <= a;
    end

    assign out = akum;

endmodule