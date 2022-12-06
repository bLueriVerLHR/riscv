`timescale 1ns / 1ps

`include "defines.v"

module visit_memory (
    input clk,
    input wen,
    input [2:0] funct3_i,
    input [`ADDR_LEN] waddr_i,
    input [`DATA_LEN] wdata_i,
    input [`ADDR_LEN] raddr_i,
    output [`DATA_LEN] rdata_o
);
    Memory mem (
        .clk(clk),
        .wen(wen),
        .funct3_i(funct3_i),
        .waddr_i(waddr_i),
        .wdata_i(wdata_i),
        .raddr_i(raddr_i),
        .rdata_o(rdata_o)
    );
endmodule
