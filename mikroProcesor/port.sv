`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Port.
    Moduł port implementuje porty wejścia/wyjścia (GPIO) z rejestrami kierunku (DDR) i rejestrami danych (PORT). Umożliwia sterowanie kierunkiem pracy poszczególnych pinów (wejście/wyjście) oraz odczyt wartości z fizycznych pinów. Dodatkowo moduł umożliwia wybór, z którego portu/pinu ma być pobierana wartość na wyjście out (do ALU).

    REQ_Port:
        REQ_Port_1: 
            Moduł ma posiadać trzy porty logiczne (A, B, C), każdy o szerokości Port_rozm_data bitów.
        REQ_Port_2: 
            Dla każdego portu istnieje rejestr kierunku DDRx.
            Wartość bitu DDRx[i] = 1 oznacza, że pin i jest w trybie wyjścia (output).
            Wartość bitu DDRx[i] = 0 oznacza, że pin i jest w trybie wejścia (input).
        REQ_Port_3: 
            Rejestry DDR są zapisywane podczas zbocza narastającego zegara clk tylko jeśli wr_DDRx = 1. Adres rejestru DDR wybierany jest przez nr_P_DDRx.
        REQ_Port_4:
            Moduł posiada rejestry danych PORTx dla każdego portu. Rejestry PORTx są zapisywane podczas zbocza narastającego zegara clk tylko jeśli wr_PORTx = 1. Adres rejestru PORT wybierany jest przez nr_P_PORTx.
        REQ_Port_5: 
            Wartości rejestrów DDR i PORT są resetowane przy rst = 1, na narastajacym zboczu zegara clk:
        REQ_Port_6: 
            Dla każdego pinu portu:
            jeśli DDRx[i] = 1, to pin fizyczny in_out_X[i] jest sterowany przez wartość PORTx[i] (tryb output).
            jeśli DDRx[i] = 0, to pin fizyczny in_out_X[i] jest w stanie wysokiej impedancji ('z'), a wartość logiczna pinu jest odczytywana na pin_mux.
        REQ_Port_7: 
            Odczyt wartości pinów w trybie wejścia (DDR=0) jest realizowany asynchronicznie i jest dostępny na out w zależności od wybranego portu/pinu.
                
*/ 
//////////////////////////////////////////////////////////////////////////////////


module port #(
      parameter Port_rozm_data = 8
      //parameter Port_liczba = 3
    )(
    input wire clk,
    input wire rst,
    input [Port_rozm_data-1:0] dane,
    input [1:0] nr_P_DDRx,
    input [1:0] nr_P_PORTx,
    input [1:0] nr_P_PINx,
    // input [$clog2(Port_liczba)-1:0] nr_P_DDRx,
    // input [$clog2(Port_liczba)-1:0] nr_P_PORTx,
    // input [$clog2(Port_liczba)-1:0] nr_P_PINx,
    input wire wr_DDRx,
    input wire wr_PORTx,

    output logic [Port_rozm_data-1:0] out,//wyjscie do ALU
    
     inout logic [7:0] in_out_A,//SW
     inout logic [7:0] in_out_B,//SW
    //inout logic [3:0] in_out_A,//SW
    //inout logic [3:0] in_out_B,//SW
    inout logic [7:0] in_out_C//diody
    );  

    wire [7:0] pin_mux [2:0];

    //DDR
    logic [7:0] rejestr_DDR [2:0]; //0-A, 1-B, 2-C
    always_ff @(posedge clk) begin : alwasyDDR  //always_ff   always @( posedge clk )
        if(rst) begin
            rejestr_DDR[0] <= '0;//SW
            rejestr_DDR[1] <= '0;//SW
            rejestr_DDR[2] <= '1;//DIODY
        end else if(wr_DDRx) begin
            rejestr_DDR[nr_P_DDRx] <= dane;  //8'b00000000 => 11111110
        end
    end

    //PORT
    logic [7:0] rejestr_PORT [2:0];
    always_ff @(posedge clk) begin : alwaysPORT  ///always_ff   always @( posedge clk ) 
        if(rst) begin
            rejestr_PORT[0] <= '0;
            rejestr_PORT[1] <= '0;
            rejestr_PORT[2] <= '0;
        end else if(wr_PORTx) begin
            rejestr_PORT[nr_P_PORTx] <= dane;
        end
    end


    //assign pin_mux[0] = (rejestr_DDR[0]) ? rejestr_PORT[0] : in_out_A;
    assign pin_mux[0][0] = (rejestr_DDR[0][0]) ? rejestr_PORT[0][0] : in_out_A[0];
    assign pin_mux[0][1] = (rejestr_DDR[0][1]) ? rejestr_PORT[0][1] : in_out_A[1];
    assign pin_mux[0][2] = (rejestr_DDR[0][2]) ? rejestr_PORT[0][2] : in_out_A[2];
    assign pin_mux[0][3] = (rejestr_DDR[0][3]) ? rejestr_PORT[0][3] : in_out_A[3];
    assign pin_mux[0][4] = (rejestr_DDR[0][4]) ? rejestr_PORT[0][4] : in_out_A[4];
    assign pin_mux[0][5] = (rejestr_DDR[0][5]) ? rejestr_PORT[0][5] : in_out_A[5];
    assign pin_mux[0][6] = (rejestr_DDR[0][6]) ? rejestr_PORT[0][6] : in_out_A[6];
    assign pin_mux[0][7] = (rejestr_DDR[0][7]) ? rejestr_PORT[0][7] : in_out_A[7];

    //assign pin_mux[1] = (rejestr_DDR[1]) ? rejestr_PORT[1] : in_out_B;
    assign pin_mux[1][0] = (rejestr_DDR[1][0]) ? rejestr_PORT[1][0] : in_out_B[0];
    assign pin_mux[1][1] = (rejestr_DDR[1][1]) ? rejestr_PORT[1][1] : in_out_B[1];
    assign pin_mux[1][2] = (rejestr_DDR[1][2]) ? rejestr_PORT[1][2] : in_out_B[2];
    assign pin_mux[1][3] = (rejestr_DDR[1][3]) ? rejestr_PORT[1][3] : in_out_B[3];
    assign pin_mux[1][4] = (rejestr_DDR[1][4]) ? rejestr_PORT[1][4] : in_out_B[4];
    assign pin_mux[1][5] = (rejestr_DDR[1][5]) ? rejestr_PORT[1][5] : in_out_B[5];
    assign pin_mux[1][6] = (rejestr_DDR[1][6]) ? rejestr_PORT[1][6] : in_out_B[6];
    assign pin_mux[1][7] = (rejestr_DDR[1][7]) ? rejestr_PORT[1][7] : in_out_B[7];
    
    //assign pin_mux[2] = (rejestr_DDR[2]) ? rejestr_PORT[2] : in_out_C;
    assign pin_mux[2][0] = (rejestr_DDR[2][0]) ? rejestr_PORT[2][0] : in_out_C[0];
    assign pin_mux[2][1] = (rejestr_DDR[2][1]) ? rejestr_PORT[2][1] : in_out_C[1];
    assign pin_mux[2][2] = (rejestr_DDR[2][2]) ? rejestr_PORT[2][2] : in_out_C[2];
    assign pin_mux[2][3] = (rejestr_DDR[2][3]) ? rejestr_PORT[2][3] : in_out_C[3];
    assign pin_mux[2][4] = (rejestr_DDR[2][4]) ? rejestr_PORT[2][4] : in_out_C[4];
    assign pin_mux[2][5] = (rejestr_DDR[2][5]) ? rejestr_PORT[2][5] : in_out_C[5];
    assign pin_mux[2][6] = (rejestr_DDR[2][6]) ? rejestr_PORT[2][6] : in_out_C[6];
    assign pin_mux[2][7] = (rejestr_DDR[2][7]) ? rejestr_PORT[2][7] : in_out_C[7];

    //wyjscie - do procka
    assign out = pin_mux[nr_P_PINx];

    //Fizyczne piny

    //assign in_out_A = (rejestr_DDR[0]) ? rejestr_PORT[0] : 'z;
    assign in_out_A[0] = (rejestr_DDR[0][0]) ? rejestr_PORT[0][0] : 'z;
    assign in_out_A[1] = (rejestr_DDR[0][1]) ? rejestr_PORT[0][1] : 'z;
    assign in_out_A[2] = (rejestr_DDR[0][2]) ? rejestr_PORT[0][2] : 'z;
    assign in_out_A[3] = (rejestr_DDR[0][3]) ? rejestr_PORT[0][3] : 'z;
    assign in_out_A[4] = (rejestr_DDR[0][4]) ? rejestr_PORT[0][4] : 'z;
    assign in_out_A[5] = (rejestr_DDR[0][5]) ? rejestr_PORT[0][5] : 'z;
    assign in_out_A[6] = (rejestr_DDR[0][6]) ? rejestr_PORT[0][6] : 'z;
    assign in_out_A[7] = (rejestr_DDR[0][7]) ? rejestr_PORT[0][7] : 'z;

    //assign in_out_B = (rejestr_DDR[1]) ? rejestr_PORT[1] : 'z;
    assign in_out_B[0] = (rejestr_DDR[1][0]) ? rejestr_PORT[1][0] : 'z;
    assign in_out_B[1] = (rejestr_DDR[1][1]) ? rejestr_PORT[1][1] : 'z;
    assign in_out_B[2] = (rejestr_DDR[1][2]) ? rejestr_PORT[1][2] : 'z;
    assign in_out_B[3] = (rejestr_DDR[1][3]) ? rejestr_PORT[1][3] : 'z;
    assign in_out_B[4] = (rejestr_DDR[1][4]) ? rejestr_PORT[1][4] : 'z;
    assign in_out_B[5] = (rejestr_DDR[1][5]) ? rejestr_PORT[1][5] : 'z;
    assign in_out_B[6] = (rejestr_DDR[1][6]) ? rejestr_PORT[1][6] : 'z;
    assign in_out_B[7] = (rejestr_DDR[1][7]) ? rejestr_PORT[1][7] : 'z;

    //assign in_out_C = (rejestr_DDR[2]) ? rejestr_PORT[2] : 'z;
    assign in_out_C[0] = (rejestr_DDR[2][0]) ? rejestr_PORT[2][0] : 'z;
    assign in_out_C[1] = (rejestr_DDR[2][1]) ? rejestr_PORT[2][1] : 'z;
    assign in_out_C[2] = (rejestr_DDR[2][2]) ? rejestr_PORT[2][2] : 'z;
    assign in_out_C[3] = (rejestr_DDR[2][3]) ? rejestr_PORT[2][3] : 'z;
    assign in_out_C[4] = (rejestr_DDR[2][4]) ? rejestr_PORT[2][4] : 'z;
    assign in_out_C[5] = (rejestr_DDR[2][5]) ? rejestr_PORT[2][5] : 'z;
    assign in_out_C[6] = (rejestr_DDR[2][6]) ? rejestr_PORT[2][6] : 'z;
    assign in_out_C[7] = (rejestr_DDR[2][7]) ? rejestr_PORT[2][7] : 'z;

endmodule