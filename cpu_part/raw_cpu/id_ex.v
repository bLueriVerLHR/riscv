`timescale 1ns / 1ps

`include "defines.v"

module id_ex (
    input  clk,
    input hold,
    input rst,

    input [`ADDR_LEN] cur_pc_i,

    // input [7:0] inst_type_i,

    input [`DATA_LEN] imm_i,

    input [`DATA_LEN] rs1_data_i,
    input [`DATA_LEN] rs2_data_i,

    input [`REG_IDX] rs1_idx_i,
    input [`REG_IDX] rs2_idx_i,
    input [`REG_IDX] rd_idx_i,

    input wb_sig_i,
    input visit_sig_i,
    input [1:0] rs1_type_i,
    input [1:0] rs2_type_i,
    input [16:0] exec_i,

    output [`ADDR_LEN] cur_pc_o,

    // output [7:0] inst_type_o,

    output [`DATA_LEN] imm_o,

    output [`DATA_LEN] rs1_data_o,
    output [`DATA_LEN] rs2_data_o,

    output [`REG_IDX] rs1_idx_o,
    output [`REG_IDX] rs2_idx_o,
    output [`REG_IDX] rd_idx_o,

    output wb_sig_o,
    output visit_sig_o,
    output [1:0] rs1_type_o,
    output [1:0] rs2_type_o,
    output [16:0] exec_o
);

    Register #(64, 64'b0) pc (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(cur_pc_i),
        .data_o(cur_pc_o)
    );

    // Register #(8, 8'b0) itype (
    //     .clk(clk),
    //     .wen(!hold),
    //     .rst(rst),
    //     .data_i(inst_type_i),
    //     .data_o(inst_type_o)
    // );

    Register #(64, 64'b0) imm (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(imm_i),
        .data_o(imm_o)
    );

    Register #(64, 64'b0) rs1_data (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(rs1_data_i),
        .data_o(rs1_data_o)
    );

    Register #(64, 64'b0) rs2_data (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(rs2_data_i),
        .data_o(rs2_data_o)
    );

    Register #(15, 15'b0) idx (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i({rs1_idx_i, rs2_idx_i, rd_idx_i}),
        .data_o({rs1_idx_o, rs2_idx_o, rd_idx_o})
    );

    Register #(6, 6'b0) sig (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i({wb_sig_i, visit_sig_i, rs1_type_i, rs2_type_i}),
        .data_o({wb_sig_o, visit_sig_o, rs1_type_o, rs2_type_o})
    );

    Register #(17, 17'b0010011_0000000_000) exec (
        .clk(clk),
        .wen(!hold),
        .rst(rst),
        .data_i(exec_i),
        .data_o(exec_o)
    );

endmodule
