`timescale 1ns / 1ps

`include "defines.v"

module Regs (
    input clk,
    input wen,
    input [`REG_IDX] rd_idx_i,
    input [`DATA_LEN] rd_wdata_i,
    input [`REG_IDX] rs1_idx_i,
    input [`REG_IDX] rs2_idx_i,
    output [`DATA_LEN] rs1_data_o,
    output [`DATA_LEN] rs2_data_o
);
    reg [`DATA_LEN] regs [31:0];

    always @(posedge clk) begin
        if (!wen) begin
            regs[rd_idx_i] <= rd_wdata_i;
        end
    end

    assign rs1_data_o = (!wen & rd_idx_i == rs1_idx_i) ? rd_wdata_i : regs[rs1_idx_i];
    assign rs2_data_o = (!wen & rd_idx_i == rs2_idx_i) ? rd_wdata_i : regs[rs2_idx_i];

endmodule
