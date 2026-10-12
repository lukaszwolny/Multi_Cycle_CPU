`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pamiec_prog#(
        parameter ADDR_WIDTH = 8,
        parameter DATA_WIDTH = 16
    )(
        input wire [ADDR_WIDTH-1:0] a,
        output logic [DATA_WIDTH-1:0] out
    );

    logic [DATA_WIDTH-1:0] ROM [(1<<ADDR_WIDTH)-1:0]; // 1<<ADDR_WIDTH 1 przesuniete w lewo o 8. czyli 2^8.
    //logic [DATA_WIDTH-1:0] ROM [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        //inicjalizacja pamieci
        $readmemb("../mem/imemfile_20.mem",ROM);//imemfile_1.mem(tak w vivado)
    end 

    assign out = ROM[a];

endmodule