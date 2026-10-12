`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

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