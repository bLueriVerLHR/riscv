`timescale 1ns / 1ps

`include "defines.v"

module Inst_Memory (
    input  clk,
    input  wen,
    input  [`ADDR_LEN] waddr_i,
    input  [`INST_LEN] wdata_i,
    input  [`ADDR_LEN] raddr_i,
    output [`INST_LEN] rdata_o
);
    parameter MEM_SIZE = 4096;
    
    reg [`INST_LEN] mem [4096:0];

    always @(posedge clk) begin
        if (!wen) begin
            mem[waddr_i[31:2]] <= wdata_i;
        end
    end

    assign rdata_o = (!wen && waddr_i == raddr_i) ? wdata_i : mem[raddr_i[31:2]];
    
    initial begin: init_imem
        integer i;
        mem[ 0] = 32'b0000000_00001_00001_000_00001_0110011; // add x1, x1, x1
        mem[ 1] = 32'b0000001_11111_00000_000_00001_0010011; // addi x1, x0, 63
        mem[ 2] = 32'b0000011_11111_00000_000_00010_0010011; // addi x2, x0, 127
        mem[ 3] = 32'b0000000_00010_00001_000_00001_0110011; // add x1, x1, x2
        mem[ 4] = 32'b0000000_00001_00001_101_00001_0010011; // srli x1, x1, 1
        mem[ 5] = 32'b0000000_00000_00001_001_00100_1100011; // bne x0, x1 tag
        mem[ 6] = 32'b1111111_00000_00001_000_11001_1100011; // beq x0, x1 tag
        mem[ 7] = 32'b0000000_00011_00001_101_00001_0010011; // slli x1, x1, 3
        mem[ 8] = 32'b0000000_00010_00001_100_00001_0110011; // xor x1, x1, x2
        mem[ 9] = 32'b0000000_00010_00001_111_00001_0110011; // and x1, x1, x2
        mem[10] = 32'b0000000_00010_00001_110_00001_0110011; // or  x1, x1, x2
        mem[11] = 32'b0000000_00001_00000_010_10000_0100011; // sw  x1, x0, 16
        mem[12] = 32'b0000000_10000_00000_010_00010_0000011; // lw  x2, x0, 16
        mem[13] = 32'b0011011_11111_00000_000_00010_0010011; // addi x2, x0, imm
        mem[14] = 32'b0011011_10011_00010_000_00010_0010011; // addi x2, x2, imm
        mem[15] = 32'b1011011_11011_00010_000_00010_0010011; // addi x2, x2, imm
        mem[16] = 32'b1011011_11011_00010_000_00010_0010011; // addi x2, x2, imm

        for (i = 17; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'b000000000001_00010_000_00010_0010011; // addi x2, x2, imm
        end
    end
endmodule
