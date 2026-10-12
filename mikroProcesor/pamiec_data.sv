`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*


1<<ADDR_WIDTH 1 przesuniete w lewo o 8. czyli 2^8.
Stronnicowanie.
pod adresem 255 wpisywany nr strony. czyli pamiec 0-254 dostepnych x ilosc stron
*/
//////////////////////////////////////////////////////////////////////////////////


module pamiec_data #(
        parameter ADDR_WIDTH_MEM = 8,
        parameter DATA_WIDTH_MEM = 8,
        parameter DATA_WIDTH_STRONY = 4
    )
    (
    input wire clk,
    input wire rst, // do rejestru stron

    input wire wr_mem,
    input wire [ADDR_WIDTH_MEM-1:0] adres,
    input wire [DATA_WIDTH_MEM-1:0] dane,
    output logic [DATA_WIDTH_MEM-1:0] out
    );

    //widh strony = 4 czyli 16 stron moze byc
    localparam MEM_SIZE_Fizycznie = 1 << (ADDR_WIDTH_MEM + DATA_WIDTH_STRONY);//8+4=12 12bitów adres do mem->4k

    //rejestr stron
    logic [DATA_WIDTH_STRONY-1:0] strona;  //4 bity -> 16 stron

    logic [DATA_WIDTH_MEM-1:0] mem [0:MEM_SIZE_Fizycznie-1];

    //Bez resetu
    always_ff @( posedge clk) begin : always_mem //always_ff   always
        if(rst) strona <= '0;
        else begin
            if(wr_mem) begin
                //dekoder
                if(adres == 8'd255) begin //rejestr stron
                    strona <= dane[DATA_WIDTH_STRONY-1:0];
                end else
                    mem[{strona, adres}] <= dane;
            end
        end
    end

    assign out = (adres == 8'd255) ? {{(DATA_WIDTH_STRONY){1'b0}}, strona} : mem[{strona, adres}];  //{4'h0, strona}
 
endmodule
