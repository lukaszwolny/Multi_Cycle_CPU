`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pc
    #(
        parameter W = 8
    )(
        input wire clk,
        input wire rst,

        input i_pc_en,

        input wire ID_rst,
        input wire skok_pc,
        input wire skok_pc_stos,
        input wire [7:0] adres_skok_pc, // z rozkazu
        input wire [7:0] adres_skok_pc_stos, // ze stosu
        output logic [W-1:0] PC_count,
        input wire reti_int_en // jak reti to int_en jest + skok_pc i skok_pc_stos i wtedy bez +1
    );

    logic [W-1:0] pc_count_s;

    always_ff @(posedge clk) begin
        if(rst || ID_rst) PC_count <= '0;
        else if(i_pc_en) PC_count <= pc_count_s;
    end

    always_comb begin
        if(skok_pc) begin
            if(skok_pc_stos) begin
                pc_count_s = adres_skok_pc_stos;
            end else begin
                pc_count_s = adres_skok_pc - 1'b1;//odjecie 1 bo poem i tak fetch +1 jest.
            end
        end else begin
            pc_count_s = PC_count + 1'b1;
        end
    end



endmodule
