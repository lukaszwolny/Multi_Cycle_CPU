`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    ALU.
    Moduł ALU realizuje jednostkę arytmetyczno-logiczną procesora odpowiedzialną za wykonywanie operacji logicznych, arytmetycznych oraz modyfikujących dane wejściowe. Operacja wykonywana przez ALU jest wybierana za pomocą kodu sterującego alu_op. Moduł generuje wynik operacji oraz zestaw flag, które odzwierciedlają właściwości wyniku i mogą być wykorzystywane przez procesor.

    REQ_ALU:
        REQ_ALU_1:
            Moduł musi realizować operacje arytmetyczno-logiczne na danych wejściowych a i b o szerokości określonej parametrem ALU_rozm_data.
        REQ_ALU_2:
            Wybór operacji wykonywanej przez ALU musi być realizowany na podstawie 4-bitowego sygnału sterującego alu_op.
        REQ_ALU_3:
            Dla kodu operacji alu_op = 0000 moduł musi przekazywać dane z wejścia b bez modyfikacji na wyjście out.
        REQ_ALU_4:
            Dla kodów operacji alu_op = 0001, 0010 oraz 0011 moduł musi realizować odpowiednio operacje logiczne AND, OR oraz XOR na wejściach a i b.
        REQ_ALU_5:
            Dla kodu operacji alu_op = 0100 moduł musi realizować operację dodawania (a + b) z generacją flagi przeniesienia.
        REQ_ALU_6:
            Dla kodu operacji alu_op = 0101 moduł musi realizować operację odejmowania (a - b) z generacją flagi przeniesienia.
        REQ_ALU_7:
            Dla kodu operacji alu_op = 0110 moduł musi realizować inkrementację wartości wejścia a.
        REQ_ALU_8:
            Dla kodu operacji alu_op = 0111 moduł musi realizować operację negacji bitowej wejścia a.
        REQ_ALU_9:
            Dla kodów operacji alu_op = 1000 oraz 1001 moduł musi realizować odpowiednio operacje dodawania i odejmowania z przeniesieniem, wykorzystując sygnał wejściowy C_in.
        REQ_ALU_10:
            Moduł musi generować flagę zera (Z), która jest ustawiona, gdy wynik operacji jest równy zero.
        REQ_ALU_11:
            Moduł musi generować flagę znaku (S) na podstawie najstarszego bitu wyniku operacji.
        REQ_ALU_12:
            Moduł musi generować flagę parzystości (P), która jest ustawiona, gdy liczba jedynek w wyniku operacji jest parzysta.
        REQ_ALU_13:
            Moduł musi generować flagę przeniesienia (C) dla operacji arytmetycznych.
        REQ_ALU_14:
            Moduł musi generować flagę przepełnienia arytmetycznego (OV) zgodnie z zasadami arytmetyki ze znakiem.
           
 Wszystkie operacje ALU oraz generacja flag muszą być realizowane kombinacyjnie, bez wykorzystania sygnału zegarowego.
*/
//////////////////////////////////////////////////////////////////////////////////

module ALU #(
    parameter ALU_rozm_data = 8
)(
    input wire [ALU_rozm_data-1:0] a,
    input wire [ALU_rozm_data-1:0] b,
    input wire [3:0] alu_op,

    output logic [ALU_rozm_data-1:0] out,

    input wire C_in,
    
    output wire P, Z, S,
    output wire C, OV
    );

    logic carry;

    always_comb begin : blockName  //always_comb  always @(*) 
        carry = 0;
        case(alu_op)
        4'b0000: begin
            //0 - LD
            out = b;
        end
        4'b0001: begin
            //1 - AND
            out = a & b;
        end
        4'b0010: begin
            //2 - OR
            out = a | b;
        end
        4'b0011: begin
            //3 - XOR
            out = a ^ b;
        end
        4'b0100: begin
            //4 - ADD
            {carry, out} = a + b;
        end
        4'b0101: begin
            //5 - SUB
            {carry, out} = a - b;
        end
        4'b0110: begin
            //6 - INK
            out = a + 1'b1;
        end
        4'b0111: begin
            //7 - NOT
            out = ~a;
        end
        4'b1000: begin
            //8 - ADDC
            {carry, out} = a + b + C_in;
        end
        4'b1001: begin
            //9 - SUBC
            {carry, out} = a - b - C_in;
        end
        default: out = b;
    endcase    
    end

//flagi
assign P = ~^out;//parzystosc
assign Z = ~|out;//zero //~(out[7] | out[6] | out[5] | out[4] | out[3] | out[2] | out[1] | out[0]);
assign S = out[7];//znak

assign OV = (a[7] & b[7] & ~out[7]) | (~a[7] & ~b[7] & out[7]);
assign C = carry;// : 1'b1 ? 1'b0;

endmodule