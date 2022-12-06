`timescale 1ns / 1ps

`include "defines.v"

module forwarding (
    input wb_pipe_sig,
    input wb_final_sig,

    input [`REG_IDX] rs1_idx_i,
    input [`REG_IDX] rs2_idx_i,
    input [1:0] cur_rs1_type_i,
    input [1:0] cur_rs2_type_i,

    input [`REG_IDX] rd_idx_pipe_i,
    input [`DATA_LEN] rd_pipe_data_i,

    input [`REG_IDX] rd_idx_final_i,
    input [`DATA_LEN] rd_final_data_i,

    output rs1_fwd_sig,
    output rs2_fwd_sig,
    output [`DATA_LEN] rs1_fwd_data_o,
    output [`DATA_LEN] rs2_fwd_data_o
);
    wire rs1_using;
    wire rs1_pipe_ing;
    wire rs1_write_back_ing;
    assign rs1_pipe_ing = ~wb_pipe_sig & (rd_idx_pipe_i == rs1_idx_i);
    assign rs1_write_back_ing = ~wb_final_sig & (rd_idx_final_i == rs1_idx_i);
    assign rs1_using = cur_rs1_type_i == `RS_RAW;

    assign rs1_fwd_sig = ~(rs1_using & (rs1_pipe_ing | rs1_write_back_ing));
    assign rs1_fwd_data_o = rs1_pipe_ing ? rd_pipe_data_i :
                            rs1_write_back_ing ? rd_final_data_i :
                            64'b0;

    wire rs2_using;
    wire rs2_pipe_ing;
    wire rs2_write_back_ing;
    assign rs2_pipe_ing = ~wb_pipe_sig & (rd_idx_pipe_i == rs2_idx_i);
    assign rs2_write_back_ing = ~wb_final_sig & (rd_idx_final_i == rs2_idx_i);
    assign rs2_using = cur_rs2_type_i == `RS_RAW;

    assign rs2_fwd_sig = ~(rs2_using & (rs2_pipe_ing | rs2_write_back_ing));
    assign rs2_fwd_data_o = rs2_pipe_ing ? rd_pipe_data_i :
                            rs2_write_back_ing ? rd_final_data_i :
                            64'b0;

endmodule
