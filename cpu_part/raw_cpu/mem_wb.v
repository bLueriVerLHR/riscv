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
    
    input wb_sig_i,
    input visit_sig_i,
    output wb_sig_o,
    output visit_sig_o,
    input wmem_en_i,
    output wmem_en_o
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
        .data_i({rd_idx_i, wb_sig_i, visit_sig_i, wmem_en_i}),
        .data_o({rd_idx_o, wb_sig_o, visit_sig_o, wmem_en_o})
    );
endmodule
