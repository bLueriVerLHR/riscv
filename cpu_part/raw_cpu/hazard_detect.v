`timescale 1ns / 1ps

`include "defines.v"

module hazard_detect (
    // input clk,
    input jal_jmp,
    input [`ADDR_LEN] jal_jmp_addr_i,
    input latter_jmp,
    input [`ADDR_LEN] latter_jmp_addr_i,
    input [`ADDR_LEN] cur_pc_i,
    input [`REG_IDX] rs1_idx_i,
    input [`REG_IDX] rs2_idx_i,
    input [1:0] rs1_type_i,
    input [1:0] rs2_type_i,
    input [6:0] former_opcode,
    input [`REG_IDX] former_inst_rd_i,
    output jmp,
    output ld_hold,
    output jmp_hold,
    output [`ADDR_LEN] jmp_addr_o
);
    assign ld_hold = ((former_opcode == `OP_LOAD) && (
        ((rs1_idx_i == former_inst_rd_i) && (rs1_type_i == `RS_RAW)) ||
        ((rs2_idx_i == former_inst_rd_i) && (rs2_type_i == `RS_RAW))
        )) ? `ENABLE : `DISABLE;
    
    assign jmp_hold = latter_jmp;

    assign jmp = jal_jmp & latter_jmp;

    wire [`ADDR_LEN] jmp_addr_jal;

    assign jmp_addr_jal = !jal_jmp ? jal_jmp_addr_i : cur_pc_i;
    assign jmp_addr_o = !latter_jmp ? latter_jmp_addr_i : jmp_addr_jal;
endmodule
