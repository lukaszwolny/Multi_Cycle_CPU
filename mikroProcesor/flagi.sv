`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
  Flagi.
  Moduł flagi realizuje rejestr flag procesora, przechowujący informacje o wyniku ostatniej operacji wykonywanej przez jednostkę arytmetyczno-logiczną. Aktualizacja flag odbywa się synchronicznie z zegarem i jest kontrolowana sygnałami sterującymi, co umożliwia selektywne zapisywanie oraz kasowanie poszczególnych flag w zależności od rodzaju wykonywanej instrukcji. Moduł udostępnia aktualny stan flag do wykorzystania przez jednostkę dekodera procesora.
  
  REQ_Flagi:
    REQ_Flagi_1:
      Moduł musi przechowywać zestaw flag statusowych procesora w postaci rejestru synchronizowanego sygnałem zegarowym clk.
    REQ_Flagi_2:
      Po aktywacji sygnału reset (rst) wszystkie flagi statusowe muszą zostać wyzerowane w jednym cyklu zegarowym.
    REQ_Flagi_3:
      Aktualizacja flag statusowych musi następować wyłącznie wtedy, gdy sygnał zapisu flag (flagi_en) jest aktywny.
    REQ_Flagi_4:
      Dla operacji arytmetycznych, przy aktywnym sygnale C_OV_en, moduł musi aktualizować flagę przeniesienia (C) oraz flagę przepełnienia (OV) na podstawie sygnałów wejściowych C_in i OV_in.
    REQ_Flagi_5:
      Dla operacji logicznych, przy aktywnym sygnale C_OV_kasowanie, moduł musi kasować flagę przeniesienia (C) oraz flagę przepełnienia (OV).
    REQ_Flagi_6:
      Flagi parzystości (P), zera (Z) oraz znaku (S) muszą być aktualizowane na podstawie sygnałów wejściowych P_in, Z_in i S_in przy każdej aktywacji zapisu flag.
    REQ_Flagi_7:
      Jeżeli sygnał flagi_en jest nieaktywny, stan wszystkich flag musi pozostać niezmieniony.
    REQ_Flagi_8:
      Aktualny stan każdej z flag musi być stale dostępny na odpowiednich wyjściach modułu.
    REQ_Flagi_9:
      Wszystkie operacje zapisu i kasowania flag muszą być realizowane synchronicznie z narastającym zboczem sygnału zegarowego clk. 

*/
//////////////////////////////////////////////////////////////////////////////////

module flagi(
  input wire clk,
  input wire rst,

  input wire flagi_en,

  input wire C_OV_en,
  input wire C_OV_kasowanie,

  input wire C_in,
  input wire OV_in,
  input wire P_in,
  input wire Z_in,
  input wire S_in,

  output wire C_out,
  output wire OV_out,
  output wire P_out,
  output wire Z_out,
  output wire S_out
);

logic [7:0] rejestr_flag;

always_ff @(posedge clk) begin // always_ff
  if(rst) begin
    rejestr_flag <= '0;
  end else if(flagi_en) begin // Jesli jest zapis do Acc to zmiana flag. Jesli nie to nie zmieniaj wogole. (bo ST jest problemem)

    if(C_OV_kasowanie) begin // jesli operacje logiczne to usun te flagi
      rejestr_flag[4] <= '0;
      rejestr_flag[1] <= '0;
    end else if(C_OV_en) begin // jesli byly operacje add / sub to aktualizuj odpowiednie flagi.
      rejestr_flag[4] <= C_in;
      rejestr_flag[1] <= OV_in;
    end

    rejestr_flag[0] <= P_in; // a te to caly czas do zmiany - bo zaleza od tego co "jest" w acc tylko.
    rejestr_flag[2] <= Z_in;
    rejestr_flag[3] <= S_in;

  end
end

assign C_out = rejestr_flag[4];
assign S_out = rejestr_flag[3];
assign Z_out = rejestr_flag[2];
assign OV_out = rejestr_flag[1];
assign P_out = rejestr_flag[0];

endmodule