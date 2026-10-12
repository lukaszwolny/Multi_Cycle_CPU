`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module ALU #(
    parameter ALU_rozm_data = 8
)(
    input wire [ALU_rozm_data-1:0] a,
    input wire [ALU_rozm_data-1:0] b,
    input wire [3:0] alu_op,

    output logic [ALU_rozm_data-1:0] out,

    input wire C_in,
    
    output wire P, Z, S,
    output wire C, OV
    );

    logic carry;

    always_comb begin : blockName  //always_comb  always @(*) 
        carry = 0;
        case(alu_op)
        4'b0000: begin
            //0 - LD
            out = b;
        end
        4'b0001: begin
            //1 - AND
            out = a & b;
        end
        4'b0010: begin
            //2 - OR
            out = a | b;
        end
        4'b0011: begin
            //3 - XOR
            out = a ^ b;
        end
        4'b0100: begin
            //4 - ADD
            {carry, out} = a + b;
        end
        4'b0101: begin
            //5 - SUB
            {carry, out} = a - b;
        end
        4'b0110: begin
            //6 - INK
            out = a + 1'b1;
        end
        4'b0111: begin
            //7 - NOT
            out = ~a;
        end
        4'b1000: begin
            //8 - ADDC
            {carry, out} = a + b + C_in;
        end
        4'b1001: begin
            //9 - SUBC
            {carry, out} = a - b - C_in;
        end
        default: out = b;
    endcase    
    end

//flagi
assign P = ~^out;//parzystosc
assign Z = ~|out;//zero //~(out[7] | out[6] | out[5] | out[4] | out[3] | out[2] | out[1] | out[0]);
assign S = out[7];//znak

assign OV = (a[7] & b[7] & ~out[7]) | (~a[7] & ~b[7] & out[7]);
assign C = carry;// : 1'b1 ? 1'b0;

endmodule