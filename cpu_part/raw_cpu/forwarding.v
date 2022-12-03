`timescale 1ns / 1ps

`include "defines.v"

module forwarding (
    input [`REG_IDX] rs1_idx_i,
    input [`REG_IDX] rs2_idx_i,
    input [`REG_IDX] rd_idx_mem_i,
    input [`REG_IDX] rd_idx_ex_i,
    input [`DATA_LEN] rd_mem_i,
    input [`DATA_LEN] rd_ex_i,
    output rs1_fwd_sig_o,
    output rs2_fwd_sig_o,
    output [`DATA_LEN] rs1_fwd_data_o,
    output [`DATA_LEN] rs2_fwd_data_o
);
    wire rs1_fwd_sig_mem;
    wire rs1_fwd_sig_ex;
    wire [`DATA_LEN] rs1_fwd_data_mem;
    assign rs1_fwd_sig_mem = rs1_idx_i == rd_idx_mem_i;
    assign rs1_fwd_data_mem = rs1_fwd_sig_mem ? rd_mem_i : 64'b0;
    assign rs1_fwd_sig_ex = rs1_idx_i == rd_idx_ex_i;

    assign rs1_fwd_sig_o = rs1_fwd_sig_mem | rs1_fwd_sig_ex;
    assign rs1_fwd_data_o = rs1_fwd_sig_o ? rd_ex_i : rs1_fwd_data_mem;

    wire rs2_fwd_sig_mem;
    wire rs2_fwd_sig_ex;
    wire [`DATA_LEN] rs2_fwd_data_mem;
    assign rs2_fwd_sig_mem = rs2_idx_i == rd_idx_mem_i;
    assign rs2_fwd_data_mem = rs2_fwd_sig_mem ? rd_mem_i : 64'b0;
    assign rs2_fwd_sig_ex = rs2_idx_i == rd_idx_ex_i;
    
    assign rs2_fwd_sig_o = rs2_fwd_sig_mem | rs2_fwd_sig_ex;
    assign rs2_fwd_data_o = rs2_fwd_sig_o ? rd_ex_i : rs2_fwd_data_mem;
endmodule
