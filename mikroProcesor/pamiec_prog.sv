`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Pamiec Programu.
    Moduł pamiec_prog jest pamięcią ROM zawierającą program procesora. Na podstawie adresu wejściowego a zwraca słowo instrukcji out.
    
    REQ_PROG:
        REQ_PROG_1: 
            Moduł musi przechowywać program w postaci stałej pamięci ROM o rozmiarze 2^ADDR_WIDTH słów, gdzie każde słowo ma szerokość DATA_WIDTH bitów.
        REQ_PROG_2: 
            Na wejściu a (adres) moduł ma przyjmować wartość w zakresie [0, 2^ADDR_WIDTH - 1].
        REQ_PROG_3: 
            Moduł ma zwracać na wyjściu out zawartość komórki pamięci o adresie a w trybie asynchronicznym.

*/
//////////////////////////////////////////////////////////////////////////////////

module pamiec_prog#(
        parameter ADDR_WIDTH = 8,
        parameter DATA_WIDTH = 16
    )(
        input wire [ADDR_WIDTH-1:0] a,
        output logic [DATA_WIDTH-1:0] out
    );

    logic [DATA_WIDTH-1:0] ROM [(1<<ADDR_WIDTH)-1:0]; // 1<<ADDR_WIDTH 1 przesuniete w lewo o 8. czyli 2^8.
    //logic [DATA_WIDTH-1:0] ROM [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        //inicjalizacja pamieci
        $readmemb("../mem/imemfile_20.mem",ROM);//imemfile_1.mem(tak w vivado)
    end 

    assign out = ROM[a];

endmodule