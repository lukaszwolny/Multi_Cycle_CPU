`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module stos#(
        parameter STOS_data_rozm = 8,
        parameter STOS_Rozm = 32
    )(
        input wire clk,
        input wire rst,
        input wire push,
        input wire pop,
        input wire [STOS_data_rozm-1:0] data_in,
        output logic [STOS_data_rozm-1:0] data_out,
        output logic full,
        output logic empty
    );

    logic [STOS_data_rozm-1:0] stos_pamiec [STOS_Rozm-1:0];
    logic [$clog2(STOS_Rozm)-1:0] stos_ptr;

    always_ff @(posedge clk) begin : stos   //always_ff   always @( posedge clk ) begin
        if(rst) begin
            for(int i=0;i < STOS_Rozm; i++) begin
                stos_pamiec[i] <= '0;
            end
            stos_ptr <= '0;
            full <= '0;
            empty <= '1;
        end else begin

            if(push && !pop) begin
                stos_pamiec[stos_ptr] <= data_in;
                stos_ptr <= stos_ptr + 1'b1;
                empty <= '0;
                if(stos_ptr == STOS_Rozm - 1) full <= '1;
                //end
            end else if(pop && !push) begin
                stos_ptr <= stos_ptr - 1'b1;
                full <= '0;
                if(stos_ptr == 1) empty <= '1;
                //end
            end
            
        end
    end

    always_comb begin   //always_comb   always @(*) begin : blockName
        if(pop && !empty) begin
           data_out = stos_pamiec[stos_ptr - 1'b1];//1
        end else begin
           data_out = '0;
        end
    end

endmodule