`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Procesor.
*/
//////////////////////////////////////////////////////////////////////////////////

module procesor(
    input wire clk,
    //input wire BTND, //przycisk jako clk - DO TESTOW.
    input wire button_c,//rst reset globalny
    
    //przerwanie ext
    input wire przerwanie_zewnetrzne,

    //inout [15:0] SW, //przyciski 

    //Na labach (plytka Intela) przycisk aktywny stanem 0!! - UWAGA na TB - tam tez to zmienic rst
    //quartus
    // inout [7:0] SW_A, //przyciski 
    // inout [7:0] SW_B, //przyciski 
    // inout [7:0] LED //8 diody

    //Dioda do oznaczanie ERROR jako wyjatek ze stosu -
    output logic dioda_error, // i w procesor.sv bedzie zapamietywany stan z ID(jak error ze stosem bedzie) i wystawiany na diode(zapali sie)
    
    inout logic [7:0] in_out_A,//SW 
    inout logic [7:0] in_out_B,//SW, albo przycisk
    inout logic [7:0] in_out_C//diody

    );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //parametry

    localparam P_PROG_data = 16;//16bit ROZKAZ
    localparam P_PROG_addres = 8;//adres 2^8=256komórek po 15bitow.
    //Rejestry
    localparam P_Rx_ILE = 8; //ile tych rejestrow

    //Dane (8bitowy procesor)
    localparam P_PROC_data = 8;//rozmiar danych
    localparam P_MEM_address = 8;

    //Porty - liczba A,B,C. 3 PORTY POPROSTU

    //Stos - wielkosc
    localparam P_STOS_depth = 32;   //32 normalnie . Testy = 5;

    //pamiec DANYCH - strony.
    localparam DATA_szerokosc_strony = 4;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //sygnaly miedzy elementami

    wire pc_rst;
    wire [P_PROG_addres-1:0] pc_licznik;
    wire [P_PROG_data-1:0] rozkaz;
    wire [P_PROG_addres-1:0] address;
    wire [$clog2(P_Rx_ILE)-1:0] numer_Rx;
    wire [P_PROC_data-1:0] stala_zmienna;
    wire [1:0] nr_DDRx;
    wire [1:0] nr_PORTx;
    wire [1:0] nr_PINx;
    wire wr_Rx;
    wire wr_MEM;
    wire wr_DDRx;
    wire wr_PORTx;
    wire mux_address;
    wire a_ce;
    wire [3:0] alu_op;
    wire [2:0] MUX_im_rx_mem_port;

    wire [P_PROC_data-1:0] data;//dane ( z Akumulatora )

    //skok ...JMP itp
    wire skok;
    wire [7:0] adres_skoku;
    //skok ...CALL..
    wire skok_stos;

    //z duzego MUXa
    wire [P_PROC_data-1:0] out_Rx;
    wire [P_PROC_data-1:0] out_MEM;
    wire [P_PROC_data-1:0] out_Port;

    wire [P_PROC_data-1:0] out_alu;
    
    //flagi
    wire carry;
    wire znak_S, parzystosc_P, zero_Z, nadmiar_OV, przepelnienie_C;
    wire ID_S, ID_P, ID_Z, ID_OV;
    wire ID_C_OV_en;
    wire ID_C_OV_kasowanie;

    //stos
    wire stos_push;
    wire stos_pop;
    wire stos_empty;
    wire stos_full;
    wire [P_PROC_data-1:0] stos_data;//dane ( ze STOSU )
    
    //stos dla pc
    wire stos_pc_push;
    wire stos_pc_pop;
    wire stos_pc_empty;
    wire stos_pc_full;
    wire [P_PROG_addres-1:0] stos_pc_data;//dane ( ze STOSU pc )

    //przerwanie
    wire przerwanie_on;
    wire przerwanie_off;
    wire [7:0] przerwanie_wektor;
    wire przerw;//przerwanie

    //Licznik
    wire [7:0] wartosc_do_licznika;
    wire zapisz_Low;
    wire zapisz_High;
    wire zapisz_control;
    wire licznik_przerwanie;
    wire flaga_licznik;
    wire flaga_clear_licznik;

    //Dioda error
    wire dioda_err;
    logic dioda_error_reg;

    wire pc_en;

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // dioda_error
    always_ff @(posedge clk) begin   //always_ff  always @(posedge clk)
      if(button_c) begin//~button_c
        dioda_error <= '0; //albo 1 - ma nie swiecic.
        dioda_error_reg <= '0;
      end else begin
        if(dioda_err && !dioda_error_reg) begin
          dioda_error <= 1'b1;//albo 0. ma swiecic teraz
          dioda_error_reg <= 1'b1;
        end
      end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////////   



    //instancje
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //--------
    // pc, ID, pc_stos, P.PROG,
    //--------

    //PC  - licznik rozkazow
    pc #(.W(P_PROG_addres)) u_pc(
        .clk(clk),
        .rst(button_c),//~button_c
        .i_pc_en(pc_en),
        .ID_rst(pc_rst),
        .skok_pc(skok),
        .skok_pc_stos(skok_stos),
        .adres_skok_pc(adres_skoku),
        .adres_skok_pc_stos(stos_pc_data),
        .PC_count(pc_licznik),
        .reti_int_en(przerwanie_on)
    );

    //Stos - dla PC
    stos #(
        .STOS_data_rozm(P_PROG_addres),
        .STOS_Rozm(P_STOS_depth)//P_STOS_depth
    ) u_pc_stos(
        .clk(clk),
        .rst(button_c),//~button_c
        .push(stos_pc_push),
        .pop(stos_pc_pop),
        .data_in(pc_licznik),
        .data_out(stos_pc_data),
        .full(stos_pc_full),
        .empty(stos_pc_empty)
    );

    //ID - dekoder instrukcji
    ID #( .I_WIDTH(P_PROG_data),
          .ID_rozm_dana(P_PROC_data),
          .ID_rozm_adres(P_MEM_address)
    ) u_ID(
        .i_clk(clk),
        .i_rst(button_c),//~button_c
        .ID_pc_en(pc_en),
        .rozkaz(rozkaz),
        .nr_Rx(numer_Rx),
        .adres(address),
        .wartosc_IM(stala_zmienna),
        .nr_P_DDRx(nr_DDRx),
        .nr_P_PORTx(nr_PORTx),
        .nr_P_PINx(nr_PINx),
        .ID_rst(pc_rst),
        .wr_Rx(wr_Rx),
        .MUX_adres(mux_address),
        .wr_MEM(wr_MEM),
        .wr_DDRx(wr_DDRx),
        .wr_PORTx(wr_PORTx),
        .MUX_IM_Rx_MEM_PORT(MUX_im_rx_mem_port),
        .A_ce(a_ce),
        .ALU_op(alu_op),
        .skok_ID(skok),
        .adres_skok_ID(adres_skoku),
        .C_OV_en(ID_C_OV_en),
        .P_in(ID_P),
        .OV_in(ID_OV),
        .Z_in(ID_Z),
        .S_in(ID_S),
        .C_in(carry),
        .C_OV_kasowanie(ID_C_OV_kasowanie),
        .ID_push(stos_push),
        .ID_pop(stos_pop),
        .ID_stos_empty(stos_empty),
        .ID_stos_full(stos_full),
        .ID_push_pc(stos_pc_push),
        .ID_pop_pc(stos_pc_pop),
        .ID_stos_pc_empty(stos_pc_empty),
        .ID_stos_pc_full(stos_pc_full),
        .skok_pc_ID(skok_stos),
        .int_en(przerwanie_on),
        .int_dis(przerwanie_off),
        .int_vec(przerwanie_wektor),
        .jest_przerwanie(przerw),
        .licznik_wartosc(wartosc_do_licznika),
        .ID_zapisz_L(zapisz_Low),
        .ID_zapisz_H(zapisz_High),
        .ID_zapisz_control(zapisz_control),
        .ID_flaga_clear_licznik(flaga_clear_licznik),
        .ID_flaga_licznik(flaga_licznik),
        .ID_dioda_error(dioda_err)
    );

    //pamiec ROM do programu
    pamiec_prog #(
        .ADDR_WIDTH(P_PROG_addres),
        .DATA_WIDTH(P_PROG_data)
    ) u_pamiec_prog (
        .a(pc_licznik),
        .out(rozkaz)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //--------
    // uk.przerwan, Licznik
    //--------

    //przerwanie
    przerwanie u_przerwanie(
        .clk(clk),
        .rst(button_c),//~button_c
        .int_enable(przerwanie_on),
        .int_disable(przerwanie_off),
        .ext_int(przerwanie_zewnetrzne),
        .timer_int(licznik_przerwanie),
        .int_vector(przerwanie_wektor),
        .przerwanie(przerw)
    );

    //licznik
    licznik u_licznik(
        .clk(clk),
        .rst(button_c),//~button_c
        .wartosc(wartosc_do_licznika),
        .zapisz_L(zapisz_Low),
        .zapisz_H(zapisz_High),
        .zapisz_ctr(zapisz_control),
        .licznik_int(licznik_przerwanie),
        .licznik_flaga(flaga_licznik),
        .licznik_flaga_clear(flaga_clear_licznik)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //--------
    // Duzy MUX, rejestry, pamiec danych, port, stos, (+ dana natychmiastowa).
    //--------

    //MUX ten duzy:
    logic [P_PROC_data-1:0] mux_I_R_M_P;
    always_comb begin : always_MUX_IM_Rx_MEM_PORT //always_comb    always @(*) begin :
        case(MUX_im_rx_mem_port)
            3'b000: mux_I_R_M_P = stala_zmienna;//zmienna
            3'b001: mux_I_R_M_P = out_Rx;//z Rx
            3'b010: mux_I_R_M_P = out_MEM;//z MEM
            3'b011: mux_I_R_M_P = out_Port;//z Portu
            3'b100: mux_I_R_M_P = stos_data;// z Stosu
            default: mux_I_R_M_P = '0;
        endcase
    end

    //MUX addres:
    wire [7:0] address_wybor; //albo z adres albo z Rx(posrednie)
    assign address_wybor = (mux_address) ? out_Rx : address;
    
    //Rejestry
    Rejestry #(
        .Rx_liczba(P_Rx_ILE),
        .Rx_rozm_data(P_PROC_data)
    ) u_rejestry (
        .clk(clk),
        .rst(button_c),//~button_c
        .wr_Rx(wr_Rx),
        .nr_Rx(numer_Rx),
        .dane(data),
        .out(out_Rx)
    );

    //pamiec danych
    pamiec_data #(
      .ADDR_WIDTH_MEM(P_MEM_address),
      .DATA_WIDTH_MEM(P_PROC_data),
      .DATA_WIDTH_STRONY(DATA_szerokosc_strony)
    ) u_pamiec_data (
        .clk(clk),
        .rst(button_c),//~button_c
        .wr_mem(wr_MEM),
        .adres(address_wybor),
        .dane(data),
        .out(out_MEM)
    );

    //Porty
    port #(
      .Port_rozm_data(P_PROC_data)
      //.Port_liczba(P_PORT_liczba)
    ) u_port(
        .clk(clk),
        .rst(button_c),//~button_c
        .dane(data),
        .nr_P_DDRx(nr_DDRx),
        .nr_P_PORTx(nr_PORTx),
        .nr_P_PINx(nr_PINx),
        .wr_DDRx(wr_DDRx),
        .wr_PORTx(wr_PORTx),
        .out(out_Port),
        .in_out_A(in_out_A),//port A
        .in_out_B(in_out_B),//port B
        .in_out_C(in_out_C)// port C
    );

    //Stos - dla DANYCH
    stos #(
        .STOS_data_rozm(P_PROC_data),
        .STOS_Rozm(P_STOS_depth)
    ) u_stos(
        .clk(clk),
        .rst(button_c),//~button_c
        .push(stos_push),
        .pop(stos_pop),
        .data_in(data),
        .data_out(stos_data),
        .full(stos_full),
        .empty(stos_empty)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //--------
    // ALU, Acc, Flagi
    //--------

    //ALU
    ALU #(
      .ALU_rozm_data(P_PROC_data)
    ) u_alu(
        .a(data),
        .b(mux_I_R_M_P),
        .alu_op(alu_op),
        .out(out_alu),
        .C_in(carry),
        .P(parzystosc_P),
        .Z(zero_Z),
        .S(znak_S),
        .C(przepelnienie_C),
        .OV(nadmiar_OV)
    );

    //A
    Akumulator #(
      .ALU_rozm_data(P_PROC_data)
    ) u_akumulator(
        .clk(clk),
        .rst(button_c),//~button_c
        .a(out_alu),
        .A_ce(a_ce),
        .out(data)
    );

    //Flagi
    flagi u_flagi(
      .clk(clk),
      .rst(button_c),//~button_c
      .flagi_en(a_ce),
      .C_OV_en(ID_C_OV_en),
      .C_OV_kasowanie(ID_C_OV_kasowanie),
      .C_in(przepelnienie_C),
      .OV_in(nadmiar_OV),
      .P_in(parzystosc_P),
      .Z_in(zero_Z),
      .S_in(znak_S),
      .C_out(carry),
      .OV_out(ID_OV),
      .P_out(ID_P),
      .Z_out(ID_Z),
      .S_out(ID_S)
    );

    //////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////
    
endmodule