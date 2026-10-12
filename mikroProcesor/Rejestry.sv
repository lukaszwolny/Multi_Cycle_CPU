`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

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