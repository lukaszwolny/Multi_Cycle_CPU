`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module Akumulator#(
        parameter ALU_rozm_data = 8
    )(
        input wire clk,
        input wire rst,
        input wire [ALU_rozm_data-1:0] a,
        input wire A_ce,
        output logic [ALU_rozm_data-1:0] out
    );

    logic [ALU_rozm_data-1:0] akum;

    always_ff @( posedge clk ) begin : always_A  //always_ff   always @( posedge clk ) begin
        if(rst) akum <= '0;
        else if(A_ce) akum <= a;
    end

    assign out = akum;

endmodule