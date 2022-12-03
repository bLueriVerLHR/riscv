`timescale 1ns / 1ps

`include "defines.v"

module if_id (
    input clk,
    input hold,
    input rst,
    input [`ADDR_LEN] cur_pc_i,
    input [`INST_LEN] cur_inst_i,
    output [`ADDR_LEN] cur_pc_o,
    output [`INST_LEN] cur_inst_o
);
    Register cur_pc (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(cur_pc_i),
        .data_o(cur_pc_o)
    );

    Register #(32, `NOP_INST) cur_inst (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(cur_inst_i),
        .data_o(cur_inst_o)
    );
endmodule
