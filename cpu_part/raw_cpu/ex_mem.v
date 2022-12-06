`timescale 1ns / 1ps

`include "defines.v"

module ex_mem (
    input  clk,
    input hold,
    input rst,

    input  [2:0] funct3_i,
    output [2:0] funct3_o,

    input  [`REG_IDX] rd_idx_i,
    output  [`REG_IDX] rd_idx_o,

    input wb_i,
    output wb_o,

    input [`DATA_LEN] alu_i,
    output [`DATA_LEN] result_o,

    input rmem_i,
    input wmem_i,
    input [`DATA_LEN] wmem_data_i,
    output rmem_o,
    output wmem_o,
    output [`DATA_LEN] wmem_data_o
);

    Register #(3, 3'b0) info (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(funct3_i),
        .data_o(funct3_o)
    );

    Register #(64, 64'b0) res (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(alu_i),
        .data_o(result_o)
    );

    Register #(64, 64'b0) wmem (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(wmem_data_i),
        .data_o(wmem_data_o)
    );

    Register #(5, 5'b0) rd (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(rd_idx_i),
        .data_o(rd_idx_o)
    );

    Register #(3, 3'b0) sig (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i({wb_i, rmem_o, wmem_o}),
        .data_o({wb_o, rmem_o, wmem_o})
    );
endmodule
