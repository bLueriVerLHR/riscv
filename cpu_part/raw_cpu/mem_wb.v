`timescale 1ns / 1ps

`include "defines.v"

module mem_wb (
    input  clk,
    input hold,
    input rst,

    input [`DATA_LEN] raddr_i,
    output [`DATA_LEN] raddr_o,

    input [`DATA_LEN] result_i,
    output [`DATA_LEN] result_o,

    input [`REG_IDX] rd_idx_i,
    output [`REG_IDX] rd_idx_o,
    
    input wb_i,
    input rmem_i,
    input wmem_i,
    output wb_o,
    output rmem_o,
    output wmem_o
);

    Register #(64, 64'b0) res (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(raddr_i),
        .data_o(raddr_o)
    );

    Register #(64, 64'b0) wmem (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(result_i),
        .data_o(result_o)
    );

    Register #(8, 8'b0) rd (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i({rd_idx_i, wb_i, wmem_i, rmem_i}),
        .data_o({rd_idx_o, wb_o, wmem_o, rmem_o})
    );
endmodule
