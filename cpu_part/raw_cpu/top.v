`timescale 1ns / 1ps

`include "defines.v"

module top (
    input clk,
    input rst
);
    // wire rst;
    wire jmp;
    wire hold = `DISABLE;
    wire ld_hold;
    wire jmp_hold;

    wire [`ADDR_LEN] jmp_pc;
    wire [`ADDR_LEN] cur_pc;
    wire [`INST_LEN] cur_inst;

    wire ex_jmp;
    wire [`DATA_LEN] ex_jmp_addr_o;

    inst_fetch IFU (
        .clk(clk),
        .rst(rst),
        .jmp(jmp),
        .hold(hold & ld_hold),
        .jmp_pc_i(jmp_pc),
        .cur_pc_o(cur_pc),
        .cur_inst_o(cur_inst)
    );

    wire [`ADDR_LEN] id_pc_i;
    wire [`INST_LEN] id_inst_i;
    
    if_id IF_ID (
        .clk(clk),
        .rst(rst & jmp_hold), // jmp nop
        .hold(hold & ld_hold),
        .cur_pc_i(cur_pc),
        .cur_inst_i(cur_inst),
        .cur_pc_o(id_pc_i),
        .cur_inst_o(id_inst_i)
    );

    wire wb_sig;
    wire [`REG_IDX] wb_rd_idx;
    wire [`ADDR_LEN] wb_rd_data;

    wire jal_jmp;
    wire [`ADDR_LEN] jal_jmp_addr;

    wire [`DATA_LEN] id_imm_o;
    wire [`DATA_LEN] id_rs1_data_o;
    wire [`DATA_LEN] id_rs2_data_o;
    wire [`REG_IDX] id_rs1_idx_o;
    wire [`REG_IDX] id_rs2_idx_o;
    wire [`REG_IDX] id_rd_idx_o;
    wire id_wb_o;
    wire id_visit_o;
    wire [1:0] id_rs1_type_o;
    wire [1:0] id_rs2_type_o;
    wire [16:0] id_exec_o;

    inst_decode IDU (
        .clk(clk),
        .cur_pc_i(id_pc_i),
        .cur_inst_i(id_inst_i),
        .rd_wen(wb_sig),
        .rd_idx_i(wb_rd_idx),
        .rd_wdata_i(wb_rd_data),
        .jal_jmp_addr_o(jal_jmp_addr),
        .jal_jmp(jal_jmp),
        .imm_o(id_imm_o),
        .rs1_data_o(id_rs1_data_o),
        .rs2_data_o(id_rs2_data_o),
        .rs1_idx_o(id_rs1_idx_o),
        .rs2_idx_o(id_rs2_idx_o),
        .rd_idx_o(id_rd_idx_o),
        .wb(id_wb_o),
        .visit(id_visit_o),
        .rs1_type_o(id_rs1_type_o),
        .rs2_type_o(id_rs2_type_o),
        .exec_o(id_exec_o)
    );

    wire [`ADDR_LEN] ex_pc_i;
    wire [`DATA_LEN] ex_imm_i;
    wire [`DATA_LEN] ex_rs1_data_i;
    wire [`DATA_LEN] ex_rs2_data_i;
    wire [`REG_IDX] ex_rs1_idx_i;
    wire [`REG_IDX] ex_rs2_idx_i;
    wire [`REG_IDX] ex_rd_idx_i;
    wire ex_wb_i;
    wire ex_visit_i;
    wire [1:0] ex_rs1_type_i;
    wire [1:0] ex_rs2_type_i;
    wire [16:0] ex_exec_i;

    id_ex ID_EX (
        .clk(clk),
        .hold(hold),
        .rst(rst & ld_hold & jmp_hold), // ld jmp nop
        .cur_pc_i(id_pc_i),
        .imm_i(id_imm_o),
        .rs1_data_i(id_rs1_data_o),
        .rs2_data_i(id_rs2_data_o),
        .rs1_idx_i(id_rs1_idx_o),
        .rs2_idx_i(id_rs2_idx_o),
        .rd_idx_i(id_rd_idx_o),
        .wb_sig_i(id_wb_o),
        .visit_sig_i(id_visit_o),
        .rs1_type_i(id_rs1_type_o),
        .rs2_type_i(id_rs2_type_o),
        .exec_i(id_exec_o),
        .cur_pc_o(ex_pc_i),
        .imm_o(ex_imm_i),
        .rs1_data_o(ex_rs1_data_i),
        .rs2_data_o(ex_rs2_data_i),
        .rs1_idx_o(ex_rs1_idx_i),
        .rs2_idx_o(ex_rs2_idx_i),
        .rd_idx_o(ex_rd_idx_i),
        .wb_sig_o(ex_wb_i),
        .visit_sig_o(ex_visit_i),
        .rs1_type_o(ex_rs1_type_i),
        .rs2_type_o(ex_rs2_type_i),
        .exec_o(ex_exec_i)
    );

    wire [`DATA_LEN] ex_result_o;
    wire [`DATA_LEN] ex_wmem_data_o;
    wire ex_wmem_en;
    wire [`DATA_LEN] rs1_fwd;
    wire [`DATA_LEN] rs2_fwd;
    wire rs1_fwd_sig;
    wire rs2_fwd_sig;

    execute EXU (
        .cur_pc_i(ex_pc_i),
        .imm_i(ex_imm_i),
        .rs1_data_i(ex_rs1_data_i),
        .rs2_data_i(ex_rs2_data_i),
        .rs1_fwd_i(rs1_fwd),
        .rs2_fwd_i(rs2_fwd),
        .rs1_fwd_sig_i(rs1_fwd_sig),
        .rs2_fwd_sig_i(rs2_fwd_sig),
        .rs1_type_i(ex_rs1_type_i),
        .rs2_type_i(ex_rs2_type_i),
        .exec_i(ex_exec_i),
        .result_o(ex_result_o),
        .wmem_data_o(ex_wmem_data_o),
        .wmem_en(ex_wmem_en),
        .jmp(ex_jmp),
        .jmp_addr_o(ex_jmp_addr_o)
    );

    wire [`ADDR_LEN] ex_calcu_result_mem;
    wire [`DATA_LEN] mem_wdata_i;
    wire [`DATA_LEN] mem_rdata_o;
    wire mem_wmem_en_o;

    wire wb_sig_i;
    
    wire mem_visit_i;
    wire [`REG_IDX] wb_rd_idx_i;

    wire [2:0] wmem_info;

    ex_mem EX_MEM (
        .clk(clk),
        .hold(hold),
        .rst(rst),
        .funct3_i(ex_exec_i[2:0]),
        .rd_idx_i(ex_rd_idx_i),
        .wb_sig_i(ex_wb_i),
        .visit_sig_i(ex_visit_i),
        .alu_i(ex_result_o),
        .wmem_data_i(ex_wmem_data_o),
        .wmem_en_i(ex_wmem_en),
        .funct3_o(wmem_info),
        .rd_idx_o(wb_rd_idx_i),
        .wb_sig_o(wb_sig_i),
        .visit_sig_o(mem_visit_i),
        .result_o(ex_calcu_result_mem),
        .wmem_data_o(mem_wdata_i),
        .wmem_en_o(mem_wmem_en_o)
    );

    Memory MEMORY (
        .clk(clk),
        .wen(mem_wmem_en_o),
        .funct3_i(wmem_info),
        .waddr_i(ex_calcu_result_mem),
        .wdata_i(mem_wdata_i),
        .raddr_i(ex_calcu_result_mem),
        .rdata_o(mem_rdata_o)
    );

    wire [`DATA_LEN] wb_ex_result_i;
    wire [`DATA_LEN] wb_rdata_i;
    wire wb_visit_i;
    wire wb_wmem_i;

    mem_wb MEM_WB (
        .clk(clk),
        .hold(hold),
        .rst(rst),
        .raddr_i(mem_rdata_o),
        .result_i(ex_calcu_result_mem),
        .rd_idx_i(wb_rd_idx_i),
        .wb_sig_i(wb_sig_i),
        .visit_sig_i(mem_visit_i),
        .wmem_en_i(mem_wmem_en_o),
        .raddr_o(wb_rdata_i),
        .result_o(wb_ex_result_i),
        .rd_idx_o(wb_rd_idx),
        .wb_sig_o(wb_sig),
        .visit_sig_o(wb_visit_i),
        .wmem_en_o(wb_wmem_i)
    );

    write_back WB (
        .visit(wb_visit_i),
        .wmem_en(wb_wmem_i),
        .result_i(wb_ex_result_i),
        .rdata_i(wb_rdata_i),
        .rd_wdata_o(wb_rd_data)
    );

    forwarding FORWARDING (
        .rs1_idx_i(ex_rs1_idx_i),
        .rs2_idx_i(ex_rs2_idx_i),
        .rd_idx_mem_i(wb_rd_idx),
        .rd_idx_ex_i(wb_rd_idx_i),
        .rd_mem_i(wb_rdata_i),
        .rd_ex_i(ex_calcu_result_mem),
        .rs1_fwd_sig_o(rs1_fwd_sig),
        .rs2_fwd_sig_o(rs2_fwd_sig),
        .rs1_fwd_data_o(rs1_fwd),
        .rs2_fwd_data_o(rs2_fwd)
    );

    hazard_detect HAZARD_DETECT (
        // .clk(clk),
        .jal_jmp(jal_jmp),
        .jal_jmp_addr_i(jal_jmp_addr),
        .latter_jmp(ex_jmp),
        .latter_jmp_addr_i(ex_jmp_addr_o),
        .cur_pc_i(id_pc_i),
        // .cur_inst_i(id_inst_i),
        .rs1_idx_i(id_rs1_idx_o),
        .rs2_idx_i(id_rs2_idx_o),
        .rs1_type_i(id_rs1_type_o),
        .rs2_type_i(id_rs2_type_o),
        .former_opcode(ex_exec_i[16:10]),
        .former_inst_rd_i(ex_rd_idx_i),
        .jmp(jmp),
        .ld_hold(ld_hold),
        .jmp_hold(jmp_hold),
        .jmp_addr_o(jmp_pc)
    );
endmodule
