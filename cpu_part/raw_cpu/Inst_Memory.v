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
    reg [`INST_LEN] mem [4096:0];

    always @(posedge clk) begin
        if (!wen) begin
            mem[waddr_i] <= wdata_i;
        end
    end

    assign rdata_o = (!wen && waddr_i == raddr_i) ? wdata_i : mem[raddr_i];
endmodule
