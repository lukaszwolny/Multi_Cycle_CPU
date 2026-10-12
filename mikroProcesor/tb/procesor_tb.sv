`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
iverilog -g2012 -o procesor_tb.vvp ../Akumulator.sv ../ALU.sv ../ID.sv ../pamiec_data.sv ../pamiec_prog.sv ../pc.sv ../port.sv ../procesor.sv ../Rejestry.sv ../flagi.sv ../stos.sv ../przerwanie.sv ../licznik.sv procesor_tb.sv
vvp procesor_tb.vvp
gtkwave procesor_tb.vcd wave.gtkw
*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module procesor_tb;

    logic clk;
    logic rst;

    logic [7:0] LED;

    logic ext_przerwanie;
/*
    wire [7:0] in_out_A;
    wire [7:0] in_out_B;
    wire [7:0] in_out_C;

    // --- symulowane SW ---
    logic [7:0] SW_A_driver;
    logic [7:0] SW_B_driver;

    // --- podłączenie "inout" ---
    assign in_out_A = SW_A_driver;
    assign in_out_B = SW_B_driver;
    // diody in_out_C są wyjściem, w
*/
    //wire [15:0] SW;

    wire [7:0] SW;
    wire [7:0] SW1;
    wire [7:0] SW2;
    
    logic [7:0] SW_A;
    logic [7:0] SW_B;
    // logic [3:0] SW_A;
    // logic [3:0] SW_B;
    //assign SW1 = {SW_A, SW_B};
    assign SW1 = SW_A;
    assign SW2 = SW_B;

    logic dioda_error;

    //inout [7:0] SW_A;//mlodsze
    //inout [7:0] SW_B;//starsze
    //logic [7:0] LED;

    procesor u_procesor(
        .clk(clk),
        //.BTND(clk),//DO testow
        .button_c(rst),
        .in_out_A(SW1),
        .in_out_B(SW2),
        .in_out_C(LED),
        .przerwanie_zewnetrzne(ext_przerwanie),
        .dioda_error(dioda_error)
    );  


    // procesor u_procesor(
    //     .clk(clk),
    //     //.BTND(clk),//DO testow
    //     .button_c(rst),
    //     .SW_A(SW1),
    //     .SW_B(SW2),
    //     .LED(LED),
    //     .przerwanie_zewnetrzne(ext_przerwanie)
    // );  


    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
            $dumpfile("procesor_tb.vcd");
            $dumpvars(0, procesor_tb);

            #20;

            rst = 0;//1;
            ext_przerwanie = 0;
            SW_A = 8'b00000000;
            SW_B = 8'b00000000;

            #10;
            rst = 1;//0;
            #10;
            rst = 0;//1;
            #10;

            //przerwanie
            //to przerwanie dla prog 9 np w momencie adres 15 jest zapis ale pojawias ie przerwanie i po przerwaniu jeszcze raz 15 sie wykonuje juz poprawnie. (odwrotnie jak dla CALL)
            /*#70;
            ext_przerwanie = 1;
            #50;
            ext_przerwanie = 0;*/
            #70;
            ext_przerwanie = 0;
            #60;
            ext_przerwanie = 1;
            #50;
            ext_przerwanie = 0;
            // #50;
            // ext_przerwanie = 1;
            // #50;
            // ext_przerwanie = 0;
            #315;
            ext_przerwanie = 1;
            #150;
            ext_przerwanie = 0;

            //13
            SW_A = 8'b01010000;
            SW_B = 8'b00000001;
            #200;
            SW_B = 8'b00000000;
            #200;
            SW_B = 8'b00000001;
            #500;
            SW_B = 8'b00000000;
            #200;
            SW_B = 8'b00000001;
            // @(posedge u_procesor.u_ID.ID_push);
            // $display("ID_push wskaznik wskazuje na (przed push)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("PUSH   stos PRZED= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr]);
            // @(negedge u_procesor.u_ID.ID_push);
            // $display("ID_push wskaznik wskazuje na (po push)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("PUSH   stos PO= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr-1]);
            // @(posedge u_procesor.u_ID.ID_push);
            // $display("PUSH wskaznik wskazuje na (przed push)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("PUSH   stos PO= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr-1]);
            // @(negedge u_procesor.u_ID.ID_push);
            // $display("PUSH wskaznik wskazuje na(po push)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("PUSH   stos PO= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr-1]);

            // @(posedge u_procesor.u_ID.ID_pop);
            // $display("POP wskaznik wskazuje na (przed POP)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("POP   stos PO= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr-1]);
            // @(negedge u_procesor.u_ID.ID_pop);
            // $display("POP wskaznik wskazuje na(po POP)=  %h", u_procesor.u_stos.stos_ptr);
            // $display("POP   stos PO= %h", u_procesor.u_stos.stos_pamiec[u_procesor.u_stos.stos_ptr-1]);
            // @(posedge clk);
            // $display("POP wskaznik wskazuje na (przed POP)=  %h", u_procesor.u_stos.stos_ptr);
            // @(posedge clk);
            // $display("POP wskaznik wskazuje na (przed POP)=  %h", u_procesor.u_stos.stos_ptr);


            // #150;

            // SW_A = 8'b00000000;
            // // SW_B = 8'b00000000;

            // #150;
            // SW_A = 8'b11111111;
  
            // #150;
            // SW_A = 8'hA0000;
            // SW_B = 8'hB0000;

             #3000;
            ext_przerwanie = 1;
            #150;
            ext_przerwanie = 0;


            // #2000;

            // wait(u_procesor.licznik_przerwanie);


            #2000;
            $display("---- TEST DONE ----");
            $finish;
  end

endmodule
/*
/////////////////////////////////////////////////////
//Na labach (plytka Intela) przycisk aktywny stanem 0!! - UWAGA na TB - tam tez to zmienic

/////////////////////////////////////////////////////

//1.

LD #0;8'b00000000
ST DDR0;
ST DDR1;

LD #8'b11111111;
ST DDR2;

LD PIN0
ST R0
LD PIN1
ADD R0

ST PORT2

RST
*/
/*
0001 011 00000000
0011 011 00000000
0011 011 00000001
0001 011 11111111
0011 011 00000010

0001 010 00000000
0011 001 00000000
0001 010 00000001
1001 000 00000000
0011 010 00000010
0000 000 00000000

*/

/*

//2.

To samo ale test pamieci danych


LD #0;8'b00000000
ST DDR0;
ST DDR1;

LD #8'b11111111;
ST DDR2;

LD PIN0
ST address=10;

LD PIN1
ST R5;
LD addres=10;
ADD R5;

ST PORT2

RST

0001 011 00000000
0011 011 00000000
0011 011 00000001

0001 011 11111111
0011 011 00000010

0001 010 00000000    ld pin0
0011 000 00001010    st add 10

0001 010 00000001  ld pin1
0011 001 00000101   ST R5;
0001 000 00001010   LD addres=10;
1001 000 00000101   ADD R5;

0011 010 00000010

0000 000 00000000
//----

*/

/*

//3.
adres w rejestrze


LD #0;8'b00000000
ST DDR0;
ST DDR1;
LD #8'b11111111;
ST DDR2;

//zapisz pin0 w pamieci pod adresem
LD PIN0
ST address=21;
LD #21;
ST R6

//zapisz pin1 w pamieci pod adresem z rejestru
LD #37
ST R7
LD PIN1
ST address=37;


LD @R6;
ST R5;
LD @R7;
ADD R5;

ST PORT2

RST

0001 011 00000000
0011 011 00000000
0011 011 00000001
0001 011 11111111
0011 011 00000010

0001 010 00000000
0011 000 00010101                    ST address=21;
0001 011 00010101                    LD #21;
0011 001 00000110                  ST R6

0001 011 00100101                  LD #37
0011 001 00000111                  ST R7
0001 010 00000001                  LD PIN1
0011 000 00100101                 ST address=37;

0001 100 00000110                   LD @R6;
0011 001 00000101                  ST R5;
0001 100 00000111                  LD @R7;
1001 000 00000101                  ADD R5;

0011 010 00000010                 ST PORT2

0000 000 00000000  RST


*/

/*

//4 - Skok JMP


LD #0;8'b00000000
ST DDR0;
ST DDR1;

LD #8'b11111111;
ST DDR2;

petla: LD PIN0
ST R0
LD PIN1
ADD R0

ST PORT2

JMP petla (address = 5)

RST - 

*/
/*
0001 011 00000000
0011 011 00000000
0011 011 00000001
0001 011 11111111
0011 011 00000010

0001 010 00000000
0011 001 00000000
0001 010 00000001
1001 000 00000000
0011 010 00000010

0100 000 00000101

0000 000 00000000

*/

/*
==========================================================
//5.
==========================================================
// nowy rozmiar rozkazu
//Test operacji ALU - FLAGI.
==========================================================
LD #0;8'b00000000   
ST DDR0;
ST DDR1;
LD #8'b11111111;
ST DDR2;

00001 011 00000000
00011 011 00000000
00011 011 00000001
00001 011 11111111
00011 011 00000010

petla: 
LD   PIN0
ST   R0; R0 = A
LD   PIN1

00001 010 00000000
00011 001 00000000
00001 010 00000001

ST   R1; R1 = B
00011 001 00000001

---- 0: LD ----
LD   R1
00001 010 00000000
ST   PORT2

--- 1: AND ----
LD   R0
AND  R1
ST   PORT2

---- 2: OR ----
LD   R0
OR   R1
ST   PORT2

--- 3: XOR ----
LD   R0
XOR  R1
ST   PORT2

--- 4: ADD ----
LD   R0
ADD  R1
ST   PORT2

---- 5: SUB ----
LD   R0
SUB  R1
ST   PORT2

---- 6: INC ----
LD   R0
INC
ST   PORT2

---- 7: NOT ----
LD   R0
NOT
ST   PORT2

---- 8: ADDC ----
LD   R0
ADDC R1
ST   PORT2

---- 9: SUBC ----
LD   R0
SUBC R1
ST   PORT2

// C, OV
LD   PIN0
ST   R0        ; A2
LD   PIN1
ST   R1        ; B2
; ---------------------------------------------
; TEST 1: ADD  (0xFF + 0x01) → Carry + Overflow
; ---------------------------------------------
LD   #8'hFF
ST   R2
LD   #8'h01
ST   R3

LD   R2
ADD  R3
ST   PORT2
; ---------------------------------------------
; TEST 2: ADD  (0x80 + 0x80) → Overflow (signed)
; ---------------------------------------------
LD   #8'h80
ST   R2
LD   #8'h80
ST   R3

LD   R2
ADD  R3
ST   PORT2
; ---------------------------------------------
; TEST 3: SUB  (0x00 − 0x01) → Borrow (Carry=0)
; ---------------------------------------------
LD   #8'h00
ST   R2
LD   #8'h01
ST   R3

LD   R2
SUB  R3
ST   PORT2


; ---------------------------------------------
; TEST 4: SUB  (0x80 − 0x01) → Overflow
; ---------------------------------------------
LD   #8'h80
ST   R2
LD   #8'h01
ST   R3

LD   R2
SUB  R3
ST   PORT2
; =============================================
;  BLOK 4 — TESTY ADDC / SUBC Z WYMUSZONĄ FLAGĄ C
; =============================================

; ---------------------------------------------
; TEST 5: ADDC (0xFF + 0x01 + C=1)
;  Najpierw ustawiamy Carry wykonując ADD FF + 1
; ---------------------------------------------
LD   #8'hFF
ADD  #8'h01   ; ustawi Carry = 1
; teraz właściwy test

LD   #8'hFF
ST   R2
LD   #8'h01
ST   R3

LD   R2
ADDC R3
ST   PORT2
; ---------------------------------------------
; TEST 6: SUBC (0x00 − 0x00 − C=1)
;  Ustawiamy Carry=1: zrobimy operację która ustawia C
; ---------------------------------------------
LD   #8'hFF
ADD  #8'h01   ; carry = 1

LD   #8'h00
ST   R2
LD   #8'h00
ST   R3

LD   R2
SUBC R3
ST   PORT2

JMP petla (address = 5)

RST - 

*/


/*

//6
//skoki

LD #0;8'b00000000   
ST DDR0;
ST DDR1;
LD #8'b11111111;
ST DDR2;

00001 011 00000000
00011 011 00000000
00011 011 00000001
00001 011 11111111
00011 011 00000010

start:
LD   #8'hFF
ST   R0
LD   #8'h01
ST   R1

test_flaga_C:   ()
LD R0
ADD R1 //powstanie C=1
JC jest_flaga_C
LD #4
ST R7

jest_flaga_C:   (14)
ST R1 //acc = 0 zapisz w r1
LD #5
ST R7
JMP test_flaga_C;


JMP start;

==================

00001 011 11111111 LD   #8'hFF
00011 001 00000000 ST   R0
00001 011 00000001 LD   #8'h01
00011 001 00000001 ST   R1
00001 001 00000000 LD R0  .test_flaga_C:   (4)
01001 000 00000001  ADD R1
01100 000 00001001   JC jest_flaga_C      skok pod 14
00001 011 00000100  LD #4
00011 001 00000111  ST R7
00011 001 00000001  ST R1  jest_flaga_C:   (9)
00001 011 00000101  LD #5
00011 001 00000111  ST R7
00100 000 00000100   JMP test_flaga_C;
00100 000 00000000   JMP start;

==================

inne przypadki: inne skoki + resetowanie flag operacjami logicznymi

ADDC:
00001 011 11111111 LD   #8'hFF
00011 001 00000000 ST   R0
00001 011 00000001 LD   #8'h01
00011 001 00000001 ST   R1
00001 001 00000000 LD R0  .test_flaga_C:   (4)
01001 000 00000001  ADD R1
01100 000 00001001   JC jest_flaga_C      skok pod 14
00001 011 00000100  LD #4
00011 001 00000111  ST R7
00011 001 00000001  ST R1  jest_flaga_C:   (9)
10000 000 00000001  ADDC R1
00011 001 00000111  ST R7
00100 000 00000100   JMP test_flaga_C;
00100 000 00000000   JMP start;

==================

inne przypadki: inne skoki + resetowanie flag operacjami logicznymi

operacja logiczna reset flagi:
00001 011 11111111 LD   #8'hFF
00011 001 00000000 ST   R0
00001 011 00000001 LD   #8'h01
00011 001 00000001 ST   R1
00001 001 00000000 LD R0  .test_flaga_C:   (4)
01001 000 00000001  ADD R1
01110 000 00000000   NOT   (NOT acc)
01100 000 00001010   JC jest_flaga_C      skok pod 14
00001 011 00000100  LD #4
00011 001 00000111  ST R7
00011 001 00000001  ST R1  jest_flaga_C:   (10)
10000 000 00000001  ADDC R1
00011 001 00000111  ST R7
00100 000 00000100   JMP test_flaga_C;
00100 000 00000000   JMP start;


*/

/*
// 7.
STOS ( tlyko Acc)
PUSH i POP.
1.
00001 011 00001010 LD   #8'h0A
00001 011 00001010 LD   #8'h0A
10100 000 00000000  push
00001 011 00001011 LD   #8'h0B
10100 000 00000000  push
00001 011 00001100 LD   #8'h0C
10101 000 00000000  pop
2.
00001 011 00001010 LD   #8'h0A
00001 011 00001010 LD   #8'h0A
10100 000 00000000  push
00001 011 00001011 LD   #8'h0B
10100 000 00000000  push
00001 011 00001100 LD   #8'h0C
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop


3.
00001 011 00001010 LD   #8'h0A
10100 000 00000000  push
00001 011 00001011 LD   #8'h0B
10100 000 00000000  push
00001 011 00001100 LD   #8'h0C
10100 000 00000000  push
00001 011 00001100 LD   #8'h0D
10100 000 00000000  push
00001 011 00001100 LD   #8'h0E
10100 000 00000000  push
00001 011 00001100 LD   #8'hFF
10100 000 00000000  push
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop

0000101100001010 
1010000000000000 
0000101100001011 
1010000000000000 
0000101100001100 
1010000000000000 
0000101100001101 
1010000000000000 
0000101100001110 
1010000000000000 
0000101100001111 
1010100000000000  
1010100000000000  
1010100000000000  
1010100000000000  
1010100000000000  
0000000000000000

//nizej w prog jest skok(na samym dole)
00100 000 11111100

-----------------------------------------
00001 011 00001010 LD   #8'h0A
00011 001 00000000 ST   R0
00001 011 00000101 LD   #8'h05
00011 001 00000001 ST   R1
00001 001 00000000 LD R0  .test_flaga_C:   (4)
01010 000 00000001  SUB R1
00111 000 00001010   JZ jest_flaga_C      skok pod 14
10100 000 00000000  push  //push 5
00011 001 00000000     ST R0  // 5 do R0
00100 000 00000100  JMP test_flagaC
10101 000 00000000  pop  jest_flaga_C:   (10)
00011 001 00000111  ST R7
00100 000 00000100   JMP test_flaga_C;
00100 000 00000000   JMP start;

*/

/*

// 7
skoki CALL i RET.
stos dla pc test

00001 011 00001010 LD   #8'h0A
10100 000 00000000  push
00100 000 00000101  JMP 5
00000 000 00000000   // nic
00000 000 00000000   // nic
00001 011 00000010   LD   #8'h02
10110 000 00010100   call 20 /
00001 011 11111111   LD   #8'hFF  //
00000 000 00000000   ...
00000 000 00000000   //
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00000 000 00000000
00001 011 00000101 LD   #8'h05  (20)
00011 001 00000000   ST R0
00001 011 00000101 LD   #8'h05
01001 000 00000000   ADD R0
00011 001 00000000   ST R0
10111 000 00000000   RET (wroci do 6)

*/


/*

//8
//testy stronnicowania

ld im 0
00001 011 00000000
st rx 0  // R0 = 0
00011 001 00000000
ld 255
00001 011 11111111
st rx 1 // R1 = 255
00011 001 00000001
ld 10
00001 011 00001010
st rx 2 // R2 = 10
00011 001 00000010
ld rx 0
00001 001 00000000
st 255 //strona 0
00011 000 11111111
ld rx 2
00001 001 00000010
st 10  //adres 10 strona 0
00011 000 00001010
ld rx 0
00001 001 00000000
inc
01101 000 00000000
st 255 // strona 1
00011 000 11111111
ld rx 2
00001 001 00000010
inc
01101 000 00000000
st Rx 3 // R3 = 11
00011 001 00000011
st 10 // adres 10 strona 1
00011 000 00001010
ld R1
00001 001 00000001
SUB R3 // 255 - 11 = 244
01010 000 00000011
st R4 //R4 = 244
00011 001 00000100
st 255 //strona   4
00011 000 11111111
ld r2
00001 001 00000010
st 10 // adres 10 strona 4
00011 000 00001010
ld r0
00001 001 00000000
st 255 //strona 0
00011 000 11111111
ld 10
00001 000 00001010
inc
01101 000 00000000
st 255 //strona 11 
00011 000 11111111
ld 10
00001 000 00001010
ld r4
00001 001 00000100
st 255 // strona 244
00011 000 11111111
ld 10
00001 000 00001010
NOP
11111 000 00000000
NOP
11111 000 00000000
ld r3 // 11
00001 001 00000011
st 100
00011 000 01100100
ld 100
00001 000 01100100
inc
01101 000 00000000
st 105
00011 000 01101001
ld 105
00001 000 01101001


a potem 
zapisz i odczyt odrazu i zobaczyc




*/

/*
//9
//przerwanie - zewnetrzne
//w przerwaniu jest zapis Acc gdzies w pamieci a potem odczyt pod koniec.

JMP main
00100 000 00000110   //pod 6 jest main
000000000 (nic)
00000 000 00000000
ext_przerw: JMP przerwanie (pod adresem 200)
00100 000 11001000
000000000 (nic)
00000 000 00000000
licznik_przerw:
00000 000 00000000 //no nic nie ma narazue wiec puste
000000000000 (nic)
00000 000 00000000
main: sei
11000 000 00000000
LD #100
00001 011 01100100
ST R0
00011 001 00000000
LD #5
00001 011 00000101
ST R1
00011 001 00000001
LD #10
00001 011 00001010
ST R7
00011 001 00000111
petla: LD R0    //petla jest pod 13
00001 001 00000000
ADD R1
01001 000 00000001
ST R0
00011 001 00000000
JMP petla
00100 000 00001101
RST
00000 000 00000000
0000000000000 (nic pare razy)
przerwanie: push  //zapisz Acc
10100 000 00000000
LD R7
00001 001 00000111
inc
01101 000 00000000
ST R7
00011 001 00000111
pop  //przywroc acc
10101 000 00000000
RETI
11010 000 00000000
*/


/*
//10

//Licznik co 10 przerwanie innkrementuje. przerwanie zewn zeruje R7

JMP main
00100 000 00000110   //pod 6 jest main
000000000 (nic)
00000 000 00000000
ext_przerw: JMP przerwanie_1 (pod adresem 200)
00100 000 11001000
000000000 (nic)
00000 000 00000000
licznik_przerw: JMP przerwanie_2 (pod adresem 220)
00100 000 11011100
000000000000 (nic)
00000 000 00000000
main: sei
11000 000 00000000
TIMER_SET_H 00000000
11110 000 00000000
TIMER_SET_L 00001010
11011 000 00001010
TIMER_CTRL 10001001
11101 000 10001001
LD #100
00001 011 01100100
ST R0
00011 001 00000000
LD #5
00001 011 00000101
ST R1
00011 001 00000001
LD #10
00001 011 00001010
ST R7
00011 001 00000111
petla: LD R0    //petla jest pod 16
00001 001 00000000
ADD R1
01001 000 00000001
ST R0
00011 001 00000000
JMP petla
00100 000 00010000
RST
00000 000 00000000
0000000000000 (nic pare razy)
przerwanie_1: push  //zapisz Acc
10100 000 00000000
LD #0
00001 011 00000000
ST R7
00011 001 00000111
pop  //przywroc acc
10101 000 00000000
RETI
11010 000 00000000

przerwanie_2: push  //zapisz Acc
10100 000 00000000
LD R7
00001 001 00000111
inc
01101 000 00000000
ST R7
00011 001 00000111
pop  //przywroc acc
10101 000 00000000
RETI
11010 000 00000000

*/



/*
//11

//Licznik co 50 przerwanie jako flaga innkrementuje

JMP main
00100 000 00000110   //pod 6 jest main
000000000 (nic)
00000 000 00000000
ext_przerw: JMP przerwanie_1 (pod adresem 200)
00100 000 11001000
000000000 (nic)
00000 000 00000000
licznik_przerw: JMP przerwanie_2 (pod adresem 220)
00100 000 11011100
000000000000 (nic)
00000 000 00000000
main: sei
11000 000 00000000
TIMER_SET_H 00000000
11110 000 00000000
TIMER_SET_L 00110010
11011 000 00110010
TIMER_CTRL 10000001    //10000010
11101 000 10000001
LD #100
00001 011 01100100
ST R0
00011 001 00000000
LD #5
00001 011 00000101
ST R1
00011 001 00000001
LD #10
00001 011 00001010
ST R7
00011 001 00000111
petla: LD R0    //petla jest pod 16
00001 001 00000000
ADD R1
01001 000 00000001
ST R0
00011 001 00000000
IF(flaga_licznik) skok do +2
11100 000 00010101
JMP -1
00100 000 00010011
JMP petla
00100 000 00010000
RST
00000 000 00000000
0000000000000 (nic pare razy)
przerwanie_1: push  //zapisz Acc
10100 000 00000000
LD #0
00001 011 00000000
ST R7
00011 001 00000111
pop  //przywroc acc
10101 000 00000000
RETI
11010 000 00000000

przerwanie_2: push  //zapisz Acc
10100 000 00000000
LD R7
00001 001 00000111
inc
01101 000 00000000
ST R7
00011 001 00000111
pop  //przywroc acc
10101 000 00000000
RETI
11010 000 00000000

*/


/*
//12
TEST diody error

Dla stosu N=5

3.
00001 011 00001010 LD   #8'h0A
10100 000 00000000  push
00001 011 00001011 LD   #8'h0B
10100 000 00000000  push
00001 011 00001100 LD   #8'h0C
10100 000 00000000  push
00001 011 00001100 LD   #8'h0D
10100 000 00000000  push
00001 011 00001100 LD   #8'h0E
10100 000 00000000  push
00001 011 00001100 LD   #8'hFF
10100 000 00000000  push
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop
10101 000 00000000  pop


JMP main
00100 000 00000110   //pod 6 jest main
000000000 (nic)
00000 000 00000000
ext_przerw: JMP przerwanie_1 (pod adresem 200)
00100 000 11001000
000000000 (nic)
00000 000 00000000
licznik_przerw: JMP przerwanie_2 (pod adresem 220)
00100 000 11011100
000000000000 (nic)
00000 000 00000000
main: sei

00100 000 00000110
00000 000 00000000
00100 000 11001000
00000 000 00000000
00100 000 11011100
000000000000
00100 000 00000110
00000 000 00000000

0000101100001010 
1010000000000000 
0000101100001011 
1010000000000000 
0000101100001100 
1010000000000000 
0000101100001101 
1010000000000000 
0000101100001110 
1010000000000000 
0000101100001110 
1010000000000000 
0000101100001111 
1010100000000000  
1010100000000000  
1010100000000000  
1010100000000000  
1010100000000000  
0000000000000000

*/

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//TESTY NA PLYTCE
//13.
/*
Test tego przycisku jednego w porcie
i tutaj widac drgania...

//--
JMP main
00100 000 00001000            //00010100
nic-- ..000..
nic
nic---
nic
nic ---
nic --
nic
(8):
LD #0;8'b00000000
00001 011 00000000
ST DDR0; //A - SW
00011 011 00000000
LD # 8'b11111110   -> 0 - przycisk
00001 011 11111110
ST DDR1; //B - nic + 1 przycisk
00011 011 00000001
LD #8'b11111111;  //LEed
00001 011 11111111
ST DDR2;  //C - diody
00011 011 00000010
LD # 8'b11111110
00001 011 11111110
ST R7   - do R7 potrzebne do operacji OR
00011 001 00000111
LD # 0 8'b0000000
00001 011 00000000
ST R0
00011 001 00000000
ST R1 //to bedzie spr czy przycisk jest wcisniety
00011 001 00000001
ST R2
00011 001 00000010
(20) main:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000
IF Z (JZ) skok do: przycisk  -- oznacza ze wcisniety przycisk jest
00111 000 00011110
LD R0
00001 001 00000000
ST R2 //reset R2.
00011 001 00000010
//dalsza czesc programu
(26)dalej:
...
LD R1
00001 001 00000001
ST PORT2 -> na diody 
00011 010 00000010
...
JMP main
00100 000 00010100
RST
00000 000 00000000

(30) przycisk:
LD R2
00001 001 00000010
JNZ jmp: back  //spr to R2 jesli jest 0 to pierwszy raz tu jestem, jak 1 to juz bylem czyli powrot
01011 000 00100101 
INC
01101 000 00000000
ST R2
00011 001 00000010
LD R1
00001 001 00000001
INC
01101 000 00000000
ST R1
00011 001 00000001
(37)back: JMP dalej
00100 000 00011010
RST
00000 000 00000000

*/


/*
//14
to samo ale z licznikiem 20ms do usuniecia drgan
licznik + licznik_flaga


//--
JMP main
00100 000 00001000            //00010100
nic-- ..000..
nic
nic---
nic
nic ---
nic --
nic
(8):
LD #0;8'b00000000
00001 011 00000000
ST DDR0; //A - SW
00011 011 00000000
LD # 8'b11111110   -> 0 - przycisk
00001 011 11111110
ST DDR1; //B - nic + 1 przycisk
00011 011 00000001
LD #8'b11111111;  //LEed
00001 011 11111111
ST DDR2;  //C - diody
00011 011 00000010
LD # 8'b11111110
00001 011 11111110
ST R7   - do R7 potrzebne do operacji OR
00011 001 00000111
LD # 0 8'b0000000
00001 011 00000000
ST R0
00011 001 00000000
ST R1 //to bedzie spr czy przycisk jest wcisniety
00011 001 00000001
ST R2
00011 001 00000010
(20) main:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000
IF Z (JZ) skok do: przycisk  -- oznacza ze wcisniety przycisk jest
00111 000 00011110
LD R0
00001 001 00000000
ST R2 //reset R2.
00011 001 00000010
//dalsza czesc programu
(26)dalej:
...
LD R1
00001 001 00000001
ST PORT2 -> na diody 
00011 010 00000010
...
JMP main
00100 000 00010100
RST
00000 000 00000000

(30) przycisk:
//tutaj ten licznik 20ms

TIMER_CTRL off
11101 000 00000011
TIMER_SET_H 0111 1010
11110 000 01111010
TIMER_SET_L 0001 0010
11011 000 00010010
TIMER_CTRL on
11101 000 10000011

//spr ponownie czy jest wcisniety
//tak - dalej, nie - jmp back
//czekam na flage
(34) IF(flaga_licznik) TIMER_READ -- IF flagi  JF  //JF jest_flaga
11100 000 00100100
JMP 34  0010 0010
00100 000 00100010
//znou spr przycisk
(36)jest_flaga:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000

IF Z (JNZ) skok do: back  -- oznacza ze przycisk nie jest wcisniety
01011 000 00101111   //01011
(40)LD R2
00001 001 00000010
JNZ jmp: back  //spr to R2 jesli jest 0 to pierwszy raz tu jestem, jak 1 to juz bylem czyli powrot
01011 000 00101111
INC
01101 000 00000000
ST R2
00011 001 00000010
LD R1
00001 001 00000001
INC
01101 000 00000000
ST R1
00011 001 00000001
(47)back: JMP dalej
00100 000 00011010
RST
00000 000 00000000


30-36
0000000000000000
1110100000000011
1111000001111010
1101100000010010
1110100010000011
1110000000100100

*/




/*
15.
To samo tylko ze na 7seg
cyfry od 0 do 15 zapisane kod 7seg w pamieci na 1 stronie. 
adres do MEM po pośrednim (przez Rx)

//---
JMP main
00100 000 00001000            //00010100
nic-- ..000..
nic
nic---
nic
nic ---
nic --
nic
(8):
LD #0;8'b00000000
00001 011 00000000
ST DDR0; //A - SW
00011 011 00000000
LD # 8'b11111110   -> 0 - przycisk
00001 011 11111110
ST DDR1; //B - nic + 1 przycisk
00011 011 00000001
LD #8'b11111111;  //LEed
00001 011 11111111
ST DDR2;  //C - diody
00011 011 00000010
LD # 8'b11111110
00001 011 11111110
ST R7   - do R7 potrzebne do operacji OR
00011 001 00000111
LD # 0 8'b0000000
00001 011 00000000
ST R0
00011 001 00000000
ST R1 //to bedzie spr czy przycisk jest wcisniety
00011 001 00000001
ST R2
00011 001 00000010
//7seg kody
LD #1 00000001
00001 011 00000001
ST R6 //rejestr do nr stron przechowuje
00011 001 00000110
ST 255 - pod adres 255(zmiana strony na 1)
00011 000 11111111
LD # 00000001 //0
00001 011 00000001
ST 0
00011 000 00000000
LD # 01001111 //1
00001 011 01001111
ST 1
00011 000 00000001
LD # 00010010 //2
00001 011 00010010
ST 2
00011 000 00000010
LD # 00000110 //3
00001 011 10000110
ST 3
00011 000 00000011
LD # 01001100 //4
00001 011 01001100
ST 4
00011 000 00000100
LD # 00100100 //5
00001 011 00100100
ST 5
00011 000 00000101
LD # 00100000 //6
00001 011 00100000
ST 6
00011 000 00000110
LD # 00001111  //7
00001 011 00001111
ST 7
00011 000 00000111
LD # 00000000 //8
00001 011 00000000
ST 8
00011 000 00001000
LD # 00000100 //9
00001 011 00000100
ST 9
00011 000 00001001
LD # 00001000 //A
00001 011 00001000
ST 10
00011 000 00001010
LD # 01100000 //B
00001 011 01100000
ST 11
00011 000 00001011
LD # 00110001 //C
00001 011 00110001
ST 12
00011 000 00001100
LD # 01000010 //D
00001 011 01000010
ST 13
00011 000 00001101
LD # 00110000 //E
00001 011 00110000
ST 14
00011 000 00001110
LD # 00111000 //F
00001 011 00111000
ST 15
00011 000 00001111
LD R0
00001 001 00000000
ST R6
00011 001 00000110
ST 255 - zmiana strony spowrotem na 0.
00011 000 11111111
(58) main:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000
IF Z (JZ) skok do: przycisk  -- oznacza ze wcisniety przycisk jest
00111 000 01001011
LD R0
00001 001 00000000
ST R2 //reset R2.
00011 001 00000010
//dalsza czesc programu
(64)dalej:
...



LD #00001111 --zaladowanie maski
00001 011 00001111
AND R1  -maska AND R1 = 4bity 0-15
00010 000 00000001
ST R1 - zapisz -> w R1 jest adres seg do wys
00011 001 00000001
LD #00000001 
00001 011 00000001
ST 255 - zmiana na 1 strone
00011 000 11111111

LD #00000000 
00001 011 01111111
ST PORT2 -> na 7seg
00011 010 00000010

LD @R1 - zaladuj znak
00001 100 00000001
ST PORT2 -> na 7seg
00011 010 00000010




...
JMP main
00100 000 00111010
RST
00000 000 00000000
(pop 73)
(75) przycisk:
//tutaj ten licznik 20ms

TIMER_CTRL off
11101 000 00000011
TIMER_SET_H 0111 1010
11110 000 01111010
TIMER_SET_L 0001 0010
11011 000 00010010
TIMER_CTRL on
11101 000 10000011

//spr ponownie czy jest wcisniety
//tak - dalej, nie - jmp back
//czekam na flage
(pop 77)
(79) IF(flaga_licznik) TIMER_READ -- IF flagi  JF  //JF jest_flaga
11100 000 01010001
JMP 79  0100 1101
00100 000 01001111
//znou spr przycisk
(pop 79)
(81)jest_flaga:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000

IF Z (JNZ) skok do: back  -- oznacza ze przycisk nie jest wcisniety
01011 000 01011100   //01011
(pop 83)
(85)LD R2
00001 001 00000010
JNZ jmp: back  //spr to R2 jesli jest 0 to pierwszy raz tu jestem, jak 1 to juz bylem czyli powrot
01011 000 01011100
INC
01101 000 00000000
ST R2
00011 001 00000010
LD R1
00001 001 00000001
INC
01101 000 00000000
ST R1
00011 001 00000001
(pop 90)
(92)back: JMP dalej
00100 000 01000000
RST
00000 000 00000000


*/


/*

16.
push/pop -> error dioda (bez 7seg)


JMP main
00100 000 00001000            //00010100
nic-- ..000..
nic
nic---
nic
nic ---
JMP 0x06  
00100 000 00000110 
nic
(8):
LD #0;8'b00000000
00001 011 00000000
ST DDR0; //A - SW
00011 011 00000000
LD # 8'b11111110   -> 0 - przycisk
00001 011 11111110
ST DDR1; //B - nic + 1 przycisk
00011 011 00000001
LD #8'b11111111;  //LEed
00001 011 11111111
ST DDR2;  //C - diody
00011 011 00000010
LD # 8'b11111110
00001 011 11111110
ST R7   - do R7 potrzebne do operacji OR
00011 001 00000111
LD # 0 8'b0000000
00001 011 00000000
ST R0
00011 001 00000000
ST R1 //to bedzie spr czy przycisk jest wcisniety
00011 001 00000001
ST R2
00011 001 00000010
(20) main:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000
IF Z (JZ) skok do: przycisk  -- oznacza ze wcisniety przycisk jest
00111 000 00011110
LD R0
00001 001 00000000
ST R2 //reset R2.
00011 001 00000010
//dalsza czesc programu
(26)dalej:
...
LD R1
00001 001 00000001
ST PORT2 -> na diody 
00011 010 00000010
...
JMP main
00100 000 00010100
RST
00000 000 00000000

(30) przycisk:
//tutaj ten licznik 20ms

TIMER_CTRL off
11101 000 00000011
TIMER_SET_H 0111 1010
11110 000 01111010
TIMER_SET_L 0001 0010
11011 000 00010010
TIMER_CTRL on
11101 000 10000011

//spr ponownie czy jest wcisniety
//tak - dalej, nie - jmp back
//czekam na flage
(34) IF(flaga_licznik) TIMER_READ -- IF flagi  JF  //JF jest_flaga
11100 000 00100100
JMP 34  0010 0010
00100 000 00100010
//znou spr przycisk
(36)jest_flaga:
LD PIN1  //sprawdzanie tego przycisku
00001 010 00000001
OR R7
00101 000 00000111
NOT
01110 000 00000000

IF Z (JNZ) skok do: back  -- oznacza ze przycisk nie jest wcisniety
01011 000 00110000   //01011
(40)LD R2
00001 001 00000010
JNZ jmp: back  //spr to R2 jesli jest 0 to pierwszy raz tu jestem, jak 1 to juz bylem czyli powrot
01011 000 00110000
INC
01101 000 00000000
ST R2
00011 001 00000010
LD R1
00001 001 00000001
INC
01101 000 00000000
ST R1
00011 001 00000001
PUSH
10100 000 00000000
(48)back: JMP dalej
00100 000 00011010
RST
00000 000 00000000



*/


/*
17.
przerwania zew+licznik 
licznik co 1s(lub wiecej) inkrementuje (7seg). przerwanie zeruje


JMP main
00100 000 00001000            //00010100
nic
00000 000 00000000
przerwanie ext (100)
JMP 
00100 000 01100100
nic---
00000 000 00000000
przerwanie licznik (200))
JMP 
00100 000 11001000
nic ---
00000 000 00000000
JMP 0x06
00100 000 00000110
nic
00000 000 00000000
(8): LD #0;8'b00000000
00001 011 00000000
ST DDR0; //A - SW
00011 011 00000000
LD # 8'b11111110   -> 0 - przycisk
00001 011 11111110
ST DDR1; //B - nic + 1 przycisk
00011 011 00000001
LD #8'b11111111;  //LEed
00001 011 11111111
ST DDR2;  //C - diody
00011 011 00000010
LD # 8'b00000010
00001 011 00000010
ST R7   - do R7 potrzebne do 1s sprawdzania. zaladowane 2.
00011 001 00000111
LD # 0 8'b0000000
00001 011 00000000
ST R0
00011 001 00000000
ST R1 //to bedzie spr czy przycisk jest wcisniety
00011 001 00000001
ST R2
00011 001 00000010
//7seg kody
LD #1 00000001
00001 011 00000001
ST R6 //rejestr do nr stron przechowuje
00011 001 00000110
ST 255 - pod adres 255(zmiana strony na 1)
00011 000 11111111
LD # 00000001 //0
00001 011 00000001
ST 0
00011 000 00000000
LD # 01001111 //1
00001 011 01001111
ST 1
00011 000 00000001
LD # 00010010 //2
00001 011 00010010
ST 2
00011 000 00000010
LD # 00000110 //3
00001 011 10000110
ST 3
00011 000 00000011
LD # 01001100 //4
00001 011 01001100
ST 4
00011 000 00000100
LD # 00100100 //5
00001 011 00100100
ST 5
00011 000 00000101
LD # 00100000 //6
00001 011 00100000
ST 6
00011 000 00000110
LD # 00001111  //7
00001 011 00001111
ST 7
00011 000 00000111
LD # 00000000 //8
00001 011 00000000
ST 8
00011 000 00001000
LD # 00000100 //9
00001 011 00000100
ST 9
00011 000 00001001
LD # 00001000 //A
00001 011 00001000
ST 10
00011 000 00001010
LD # 01100000 //B
00001 011 01100000
ST 11
00011 000 00001011
LD # 00110001 //C
00001 011 00110001
ST 12
00011 000 00001100
LD # 01000010 //D
00001 011 01000010
ST 13
00011 000 00001101
LD # 00110000 //E
00001 011 00110000
ST 14
00011 000 00001110
LD # 00111000 //F
00001 011 00111000
ST 15
00011 000 00001111
LD R0
00001 001 00000000
ST R6
00011 001 00000110
ST 255 - zmiana strony spowrotem na 0.
00011 000 11111111
LD R2
00001 001 00000010
INC
01101 000 00000000
ST R2   //R2 = 1
00011 001 00000010
----
enable przerwania ext: sei
11000 000 00000000

enable licznik przerwania co 500ms
TIMER_CTRL off
11101 000 00000011
TIMER_SET_H 1011 1110
11110 000 00000000
TIMER_SET_L 1011 1100
11011 000 00000110
TIMER_CTRL on  + ext int en
11101 000 10001101  

(66) main:    wys na seg tego rejestru i tyle

//inkrementacja R1 jesli R7 jest 0.(czyli 1s)
LD R7
00001 001 00000111
JNZ R7 skok adres +2 (69) 
01011 000 01000101
CALL inkrementacja_podprogram . gdzies tam w pamieci
10110 000 10010110
LD #00001111 --zaladowanie maski
00001 011 00001111
AND R1  -maska AND R1 = 4bity 0-15
00010 000 00000001
ST R1 - zapisz -> w R1 jest adres seg do wys
00011 001 00000001
LD #00000001 
00001 011 00000001
ST 255 - zmiana na 1 strone
00011 000 11111111
LD @R1 - zaladuj znak
00001 100 00000001
ST PORT2 -> na 7seg
00011 010 00000010
LD #00000000 
00001 011 00000000
ST 255 - zmiana na 0 strone
00011 000 11111111
JMP main
00100 000 01000010
RST
00000 000 00000000

----  gdzies tam w pamieci --:

(100)ext przerwanie: zerowanie R1
PUSH 
10100 000 00000000
LD #00000000 
00001 011 00000000
ST R1
00011 001 00000001
POP
10101 000 00000000
RETI
11010 000 00000000
RST
00000 000 00000000

(200)ext licznik:  R7 - 1
PUSH 
10100 000 00000000
LD R7
00001 001 00000111
SUB R2
01010 000 00000010
ST R7
00011 001 00000111
POP
10101 000 00000000
RETI
11010 000 00000000
RST
00000 000 00000000

(150) inkrementacja_podprogram:
PUSH 
10100 000 00000000
LD R1
00001 001 00000001
INC
01101 000 00000000
ST R1
00011 001 00000001
LD R7
00001 001 00000111
inc
01101 000 00000000
inc
01101 000 00000000
ST R7
00011 001 00000111
POP
10101 000 00000000
RET
10111 000 00000000
RST
00000 000 00000000






*/


/*

18.
jakis kalkulator co wykorzysta doslownie wszystko.
podaje 2 liczby po SW. 1 liczba - przycisk 2 liczba


TO_DO

*/