`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Dekoder rozkazow.
    Moduł ID odpowiada za dekodowanie instrukcji maszynowych oraz generowanie sygnałów sterujących dla wszystkich podsystemów procesora. Na podstawie kodu instrukcji oraz aktualnego stanu flag, stosu, licznika i systemu przerwań, moduł decyduje o wykonaniu operacji arytmetyczno-logicznych, dostępie do pamięci i portów I/O, obsłudze skoków, przerwań oraz mechanizmów stosu i timera.

    REQ_Dekoder:
        REQ_Dekoder_1:
            Moduł ID musi dekodować instrukcję maszynową na podstawie pola operacji zawartego w rozkazie.
        REQ_Dekoder_2:
            Moduł ID musi generować sygnały sterujące umożliwiające wykonanie operacji arytmetycznych i logicznych przez jednostkę ALU.
        REQ_Dekoder_3:
            Moduł ID musi umożliwiać wybór źródła danych operandu, w tym wartości natychmiastowej, rejestru, pamięci oraz portów wejścia–wyjścia.
        REQ_Dekoder_4:
            Moduł ID musi obsługiwać instrukcje zapisu i odczytu danych do rejestrów, pamięci oraz portów I/O.
        REQ_Dekoder_5:
            Moduł ID musi obsługiwać instrukcje skoku bezwarunkowego oraz warunkowego w oparciu o aktualny stan flag procesora.
        REQ_Dekoder_6:
            Moduł ID musi obsługiwać mechanizm stosu danych oraz stosu adresów powrotu, w tym wykrywanie przepełnienia i niedomiaru stosu.
        REQ_Dekoder_7:
            Moduł ID musi obsługiwać system przerwań, w tym przyjmowanie przerwania, zapis adresu powrotu na stos oraz skok do wektora przerwania.
        REQ_Dekoder_8:
            Moduł ID musi umożliwiać konfigurację i obsługę licznika czasowego, w tym zapis rejestrów sterujących oraz reakcję na flagę licznika.
        REQ_Dekoder_9:
            Moduł ID musi generować sygnały sterujące flagami procesora w zależności od typu wykonywanej instrukcji.
        REQ_Dekoder_10:
            W przypadku wykrycia sytuacji wyjątkowych, takich jak przepełnienie stosu, moduł ID musi wygenerować odpowiednią reakcję systemową.

*/
//////////////////////////////////////////////////////////////////////////////////

module ID#(
        parameter I_WIDTH = 16,
        parameter ID_rozm_dana = 8,
        parameter ID_rozm_adres = 8
    )
    (
        input wire i_clk,
        input wire i_rst,

        input wire [I_WIDTH-1:0] rozkaz,

        output logic [2:0] nr_Rx,
        output logic [ID_rozm_adres-1:0] adres,
        output logic [ID_rozm_dana-1:0] wartosc_IM,
        output logic [1:0] nr_P_DDRx,
        output logic [1:0] nr_P_PORTx,
        output logic [1:0] nr_P_PINx,

        //sterujace
        output logic ID_pc_en,
        output logic ID_rst,
        output logic wr_Rx,// do Rx
        output logic MUX_adres,//adres albo Rx(posrednie adresowanie) do MEM
        output logic wr_MEM,
        output logic wr_DDRx,
        output logic wr_PORTx,
        output logic [2:0] MUX_IM_Rx_MEM_PORT,
        output logic A_ce,
        output logic [3:0] ALU_op,//operacje do alu

        //pc skoki
        output logic skok_ID,
        output logic [7:0] adres_skok_ID,

        //flagi
        output logic C_OV_en,
        input wire P_in, OV_in, Z_in, S_in, C_in,
        output logic C_OV_kasowanie,
        // output logic flagi_en,

        //Stos
        output logic ID_push,
        output logic ID_pop,
        input wire ID_stos_empty,
        input wire ID_stos_full,

        //pc - stos
        output logic ID_push_pc,
        output logic ID_pop_pc,
        input wire ID_stos_pc_empty,
        input wire ID_stos_pc_full,
        output logic skok_pc_ID,

        //przerwanie
        output logic int_en,
        output logic int_dis,
        input wire [7:0] int_vec,
        input wire jest_przerwanie,

        //licznik
        output logic [7:0] licznik_wartosc,
        output logic ID_zapisz_L,
        output logic ID_zapisz_H,
        output logic ID_zapisz_control,
        output logic ID_flaga_clear_licznik,
        input wire ID_flaga_licznik,

        output logic ID_dioda_error
    );

    //logic [4:0] instrukcja; // do usuniecia

    logic op_rst, op_ld, op_st, op_and, op_xor, op_jz, op_or, op_jmp, op_nop, op_add, op_jnz, op_sub, op_not, op_jp, op_inc, op_jc, op_sei, op_cli, op_timer_set_l, op_reti, op_timer_set_h, op_timer_ctrl, op_timer_r, op_addc, op_js, op_subc, op_jov, op_call, op_ret, op_pop, op_push;

    assign op_rst           =   (rozkaz[15:11] == 5'b00000);
    assign op_ld            =   (rozkaz[15:11] == 5'b00001);
    // assign op_ld_
    assign op_st            =   (rozkaz[15:11] == 5'b00011);
    // assign op_st_
    assign op_and           =   (rozkaz[15:11] == 5'b00010);
    assign op_xor           =   (rozkaz[15:11] == 5'b00110);
    assign op_jz            =   (rozkaz[15:11] == 5'b00111);
    assign op_or            =   (rozkaz[15:11] == 5'b00101);
    assign op_jmp           =   (rozkaz[15:11] == 5'b00100);
    assign op_nop           =   (rozkaz[15:11] == 5'b01000);
    assign op_add           =   (rozkaz[15:11] == 5'b01001);
    assign op_jnz           =   (rozkaz[15:11] == 5'b01011);
    assign op_sub           =   (rozkaz[15:11] == 5'b01010);
    assign op_not           =   (rozkaz[15:11] == 5'b01110);
    assign op_jp            =   (rozkaz[15:11] == 5'b01111);
    assign op_inc           =   (rozkaz[15:11] == 5'b01101);
    assign op_jc            =   (rozkaz[15:11] == 5'b01100);
    assign op_sei           =   (rozkaz[15:11] == 5'b11000);
    assign op_cli           =   (rozkaz[15:11] == 5'b11001);
    assign op_timer_set_l   =   (rozkaz[15:11] == 5'b11011);
    assign op_reti          =   (rozkaz[15:11] == 5'b11010);
    assign op_timer_set_h   =   (rozkaz[15:11] == 5'b11110);
    assign op_timer_ctrl    =   (rozkaz[15:11] == 5'b11101);
    assign op_timer_r       =   (rozkaz[15:11] == 5'b11100);
    assign op_addc          =   (rozkaz[15:11] == 5'b10000);
    assign op_js            =   (rozkaz[15:11] == 5'b10001);
    assign op_subc          =   (rozkaz[15:11] == 5'b10011);
    assign op_jov           =   (rozkaz[15:11] == 5'b10010);
    assign op_call          =   (rozkaz[15:11] == 5'b10110);
    assign op_ret           =   (rozkaz[15:11] == 5'b10111);
    assign op_pop           =   (rozkaz[15:11] == 5'b10101);
    assign op_push          =   (rozkaz[15:11] == 5'b10100);

    typedef enum logic [4:0] { 
        Fetch = 5'b00000,
        Decode,
        Exe_rst,
        Exe_ld, 
        Exe_st, 
        Exe_and, 
        Exe_xor, 
        Exe_jz, 
        Exe_or, 
        Exe_jmp, 
        //Exe_nop, 
        Exe_add, 
        Exe_jnz, 
        Exe_sub, 
        Exe_not, 
        Exe_jp, 
        Exe_inc, 
        Exe_jc, 
        Exe_sei, 
        Exe_cli, 
        Exe_timer_set_l, 
        Exe_reti, 
        Exe_timer_set_h, 
        Exe_timer_ctrl, 
        Exe_timer_r, 
        Exe_addc, 
        Exe_js, 
        Exe_subc, 
        Exe_jov, 
        Exe_call, 
        Exe_ret, 
        Exe_pop, 
        Exe_push
    } states_cycle;

    states_cycle state;
    states_cycle next_state;

    always_ff @( posedge i_clk ) begin : blockName
        if(i_rst) state <= Fetch;
        else state <= next_state;
    end

    always_comb begin
        case(state)
            Fetch: next_state = Decode;
            Decode: begin
                if(op_rst)              next_state  =   Exe_rst;
                else if(op_ld)          next_state  =   Exe_ld;
                else if(op_st)          next_state  =   Exe_st;
                else if(op_and)         next_state  =   Exe_and;
                else if(op_xor)         next_state  =   Exe_xor;
                else if(op_jz)          next_state  =   Exe_jz;
                else if(op_or)          next_state  =   Exe_or;
                else if(op_jmp)         next_state  =   Exe_jmp;
                else if(op_nop)         next_state  =   Fetch;//Exe_nop;
                else if(op_add)         next_state  =   Exe_add;
                else if(op_jnz)         next_state  =   Exe_jnz;
                else if(op_sub)         next_state  =   Exe_sub;
                else if(op_not)         next_state  =   Exe_not;
                else if(op_jp)          next_state  =   Exe_jp;
                else if(op_inc)         next_state  =   Exe_inc;
                else if(op_jc)          next_state  =   Exe_jc;
                else if(op_sei)         next_state  =   Exe_sei;
                else if(op_cli)         next_state  =   Exe_cli;
                else if(op_timer_set_l) next_state  =   Exe_timer_set_l;
                else if(op_reti)        next_state  =   Exe_reti;
                else if(op_timer_set_h) next_state  =   Exe_timer_set_h;
                else if(op_timer_ctrl)  next_state  =   Exe_timer_ctrl;
                else if(op_timer_r)     next_state  =   Exe_timer_r;
                else if(op_addc)        next_state  =   Exe_addc;
                else if(op_js)          next_state  =   Exe_js;
                else if(op_subc)        next_state  =   Exe_subc;
                else if(op_jov)         next_state  =   Exe_jov;
                else if(op_call)        next_state  =   Exe_call;
                else if(op_ret)         next_state  =   Exe_ret;
                else if(op_pop)         next_state  =   Exe_pop;
                else if(op_push)        next_state  =   Exe_push;
                else                    next_state  =   Fetch;
            end
            default: next_state = Fetch;
        endcase
    end

    //do przerwania
    logic przerwanie_r;
    logic przerwanie_clr;
    logic [7:0] int_vec_r;
    always_ff @( posedge i_clk ) begin
        if(i_rst) przerwanie_r <= '0;
        else if(jest_przerwanie) przerwanie_r <= '1;
        else if(przerwanie_clr) przerwanie_r <= '0;
    end
    always_ff @(posedge i_clk) begin
        if(i_rst) int_vec_r <= '0;
        else if(jest_przerwanie) int_vec_r <= int_vec;
    end

    always_comb begin
        ID_pc_en                =   '0;
        nr_Rx                   =   '0;
        adres                   =   '0;
        wartosc_IM              =   '0;
        nr_P_DDRx               =   '0;
        nr_P_PORTx              =   '0;
        nr_P_PINx               =   '0;
        ID_rst                  =   '0;
        wr_Rx                   =   '0;
        MUX_adres               =   '0;
        wr_MEM                  =   '0;
        wr_DDRx                 =   '0;
        wr_PORTx                =   '0;
        MUX_IM_Rx_MEM_PORT      =   '0;
        A_ce                    =   '0;
        ALU_op                  =   '0;   
        //------------------------------
        skok_ID                 =   '0;
        adres_skok_ID           =   '0;
        //------------------------------
        C_OV_en                 =   '0;
        C_OV_kasowanie          =   '0;
        //------------------------------
        ID_push                 =   '0;
        ID_pop                  =   '0;
        ID_push_pc              =   '0;
        ID_pop_pc               =   '0;
        skok_pc_ID              =   '0;
        //-----------------------
        int_en                  =   '0;
        int_dis                 =   '0;
        //-----------------------
        licznik_wartosc         =   '0;
        ID_zapisz_L             =   '0;
        ID_zapisz_H             =   '0;
        ID_zapisz_control       =   '0;
        ID_flaga_clear_licznik  =   '0;
        //-----------------------
        ID_dioda_error          =   '0;

        przerwanie_clr          =   '0;

        case(state)
            Fetch: begin
                ID_pc_en = '1;
                if(przerwanie_r) begin
                    int_dis = '1;//off  + zapis na stos + zapis pc wketor przerwaia
                    skok_ID = '1;
                    ID_push_pc = '1;
                    adres_skok_ID = int_vec_r;
                    skok_pc_ID = '0;
                    przerwanie_clr = '1;
                end
            end
            Decode:; // no nic
            Exe_rst: ID_rst = '1;   //RST
            Exe_ld: begin //LD
                case(rozkaz[10:8])
                    3'b000: begin
                        //address
                        MUX_adres = '0;
                        adres = rozkaz[7:0];
                        MUX_IM_Rx_MEM_PORT = 3'b010;//2
                        ALU_op = rozkaz[15:12];
                        A_ce = '1;
                    end
                    3'b001: begin
                        //Rx
                        nr_Rx = rozkaz[2:0];
                        MUX_IM_Rx_MEM_PORT = 3'b001;//1
                        ALU_op = rozkaz[15:12];
                        A_ce = '1;
                    end
                    3'b010: begin
                        //PINx
                        nr_P_PINx = rozkaz[1:0]; //1bit
                        MUX_IM_Rx_MEM_PORT = 3'b011;//3
                        ALU_op = rozkaz[15:12];
                        A_ce = '1;
                    end
                    3'b011: begin
                        //IM - zmienna
                        wartosc_IM = rozkaz[7:0]; //1bit
                        MUX_IM_Rx_MEM_PORT = 3'b000;//0
                        ALU_op = rozkaz[15:12];
                        A_ce = '1;
                    end
                    3'b100: begin
                        //@Rx
                        nr_Rx = rozkaz[2:0];
                        MUX_adres = '1;
                        MUX_IM_Rx_MEM_PORT = 3'b010;//2
                        ALU_op = rozkaz[15:12];
                        A_ce = '1;
                    end
                endcase
            end
            Exe_st: begin //ST
                case(rozkaz[9:8])
                    2'b00: begin //address
                        wr_MEM = '1;
                        MUX_adres = '0;
                        adres = rozkaz[7:0];
                    end
                    2'b01: begin //Rx
                        wr_Rx = '1;
                        nr_Rx = rozkaz[2:0];
                    end
                    2'b10: begin //PORTx
                        wr_PORTx = '1;
                        nr_P_PORTx = rozkaz[1:0];
                    end
                    2'b11: begin //DDRx
                        wr_DDRx = '1;
                        nr_P_DDRx = rozkaz[1:0];
                    end
                endcase
            end
            Exe_and: begin //AND
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_kasowanie = '1;
            end
            Exe_xor: begin //XOR
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_kasowanie = '1;
            end
            Exe_jz: begin //JZ  
                if(Z_in) begin
                    
                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end
            end
            Exe_or: begin //OR
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_kasowanie = '1;
            end
            Exe_jmp: begin //JMP 

                ID_pc_en = '1;

                skok_ID = '1;
                adres_skok_ID = rozkaz[7:0];
            end
            //Exe_nop: 
            Exe_add: begin //ADD
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_en = '1;
            end
            Exe_jnz: begin //JNZ
                if(!Z_in) begin
                    
                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end                
            end
            Exe_sub: begin //SUB
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_en = '1;
            end
            Exe_not: begin //NOT
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                C_OV_kasowanie = '1;   
            end
            Exe_jp: begin //JP
                if(P_in) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end                    
            end
            Exe_inc: begin //INC
                ALU_op = rozkaz[15:12];
                A_ce = '1;
            end
            Exe_jc: begin //JC
                if(C_in) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end                
            end
            Exe_sei: begin //SEI  -- on
                int_en = '1;
            end
            Exe_cli: begin //CLI  -- off
                int_dis = '1;        
            end
            Exe_timer_set_l: begin //TIMER_SET_L  --ustawia wartosc wartosc-max.
                licznik_wartosc = rozkaz[7:0];
                ID_zapisz_L = '1;
            end
            Exe_reti: begin //RETI  -- powrot z przerwania. on+ze stosu

                ID_pc_en = '1;

                int_en = '1;
                ID_pop_pc = '1;
                skok_ID = '1;
                skok_pc_ID = '1;                    
            end
            Exe_timer_set_h: begin //TIMER_SET_H
                licznik_wartosc = rozkaz[7:0];
                ID_zapisz_H = '1;
            end
            Exe_timer_ctrl: begin //TIMER_CTRL  --ctr
                licznik_wartosc = rozkaz[7:0];
                ID_zapisz_control = '1;
            end
            Exe_timer_r: begin //TIMER_READ -- IF flagi  JF
                if(ID_flaga_licznik) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];
                    ID_flaga_clear_licznik = '1;
                end
            end
            Exe_addc: begin //ADDC
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_en = '1;                
            end
            Exe_js: begin //JS
                if(S_in) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end                 
            end
            Exe_subc: begin //SUBC
                ALU_op = rozkaz[15:12];
                A_ce = '1;
                MUX_IM_Rx_MEM_PORT = 3'b001;//1
                nr_Rx = rozkaz[2:0];
                C_OV_en = '1;                
            end
            Exe_jov: begin //JOV
                if(OV_in) begin

                    ID_pc_en = '1;
                    
                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];                    
                end                 
            end
            Exe_call: begin //CALL
                if(ID_stos_pc_full) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                    ID_dioda_error = '1;
                    int_dis = '1;
                end else begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    ID_push_pc = '1;
                    adres_skok_ID = rozkaz[7:0];
                    skok_pc_ID = '0;
                end
            end
            Exe_ret: begin //RET
                if(ID_stos_pc_empty) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                    ID_dioda_error = '1;
                    int_dis = '1;
                end else begin

                    ID_pc_en = '1;

                    ID_pop_pc = '1;
                    skok_ID = '1;
                    skok_pc_ID = '1;
                end
            end
            Exe_pop: begin //POP  ACC <- STOS
                if(ID_stos_empty) begin

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                    ID_dioda_error = '1;
                    int_dis = '1;
                end else begin
                    ID_pop = '1;
                    ALU_op = '0;
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b100;//4
                end
            end
            Exe_push: begin //PUSH  STOS <- ACC
                if(ID_stos_full) begin
                    //wyjatek od przpelnienia

                    ID_pc_en = '1;

                    skok_ID = '1;
                    adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                    ID_dioda_error = '1;
                    int_dis = '1; // off przerwania
                end else begin
                    ID_push = '1;
                end
            end
            default:;
        endcase
    end

endmodule