`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

Przerwanie bez masek i priorytet ma zewnetrzne przerwanie nad licznikiem
To idzie najpierw do ID a potem do pc z ID idzie       
*/
//////////////////////////////////////////////////////////////////////////////////

module przerwanie(
    input wire clk,
    input wire rst,
    input wire int_enable,//sei  + RETI
    input wire int_disable,//cli
    input wire ext_int,//zewnetrzne przerwanie .. przycisk
    input wire timer_int,//wewnetrzne przerwanie z licznika
    output logic [7:0] int_vector, //wektor przerwania
    output logic przerwanie
);

logic przerwanie_en;
logic ext_int_prev;//do wykrycia zbocza
logic timer_int_prev;
logic int_a; // przerwanie przycisk
logic int_b; //przerwanie timer

always_ff @(posedge clk) begin    //always_ff
    if(rst) begin
        przerwanie_en <= '0;
        przerwanie <= '0;
        ext_int_prev <= '0;
        timer_int_prev <= '0;
        int_a <= '0;
        int_b <= '0;
        int_vector <= '0;
    end else begin
        
        przerwanie <= '0;
        int_vector <= '0;

        //enable/disable
        if(int_enable) begin 
            przerwanie_en <= 1'b1; 
        end else if(int_disable) begin
            przerwanie_en <= 1'b0; 
        end

        //zbocze i ext_int_en
        ext_int_prev <= ext_int;
        timer_int_prev <= timer_int;
        if(/*przerwanie_en && */ext_int && ~ext_int_prev) begin //Tutaj dla przerwania zewnetrznego - ma piorytet. Jak sie pojawi to, sie zapisuje i czeka az ponownie bedzie int_enable. - zapisuje sie nawet jak jest disaple
            int_a <= 1'b1;
        end
        if(przerwanie_en && timer_int && ~timer_int_prev) begin
            int_b <= 1'b1;
        end

        //priorytet
        if(int_a && przerwanie_en) begin
            przerwanie <= 1'b1;
            int_vector <= 8'h03;//8'h02;
            int_a <= '0;
        end else if(int_b && przerwanie_en && ~przerwanie) begin
            przerwanie <= 1'b1;
            int_vector <= 8'h05;//8'h04;
            int_b <= '0;
        end
    end
end

endmodule