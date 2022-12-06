`timescale 1ns / 1ps

`include "defines.v"

module top (
    input clk,
    input rst
    // output [`ADDR_LEN] dbg_if_pc_o,
    // output [`INST_LEN] dbg_if_inst_o,
    // output [`ADDR_LEN] dbg_if_jmp_pc_o,

    // output [`DATA_LEN] dbg_id_rs1,
    // output [`DATA_LEN] dbg_id_rs2,
    // output [`DATA_LEN] dbg_id_imm_o,
    // output [`REG_IDX] dbg_id_rs1_idx,
    // output [`REG_IDX] dbg_id_rs2_idx,
    // output [`REG_IDX] dbg_id_rd_idx,
    // output [1:0] dbg_id_op1_sel,
    // output [1:0] dbg_id_op2_sel,
    // output [6:0] dbg_id_opcode,
    // output [2:0] dbg_id_funct3,
    // output [6:0] dbg_id_funct7,
    // output dbg_id_wb,
    // output dbg_id_rmem,
    // output dbg_id_wmem,

    // output [`DATA_LEN] dbg_ex_result_o,
    // output dbg_ex_latter_jmp,

    // output [`DATA_LEN] dbg_mem_rmem_o,

    // output [`DATA_LEN] dbg_wb_rd_data_o,

    // output dbg_fwd_op1_sig,
    // output dbg_fwd_op2_sig,
    // output [`DATA_LEN] dbg_fwd_op1_data,
    // output [`DATA_LEN] dbg_fwd_op2_data,

    // output dbg_hzd_jmp,
    // output dbg_hzd_ld
);
    // eee
    wire hold = `DISABLE;

    wire if_jmp_i;
    wire [`ADDR_LEN] if_jmp_pc_i;

    wire hzd_load_hold;
    wire hzd_jmp_hold;

    wire [`ADDR_LEN] if_cur_pc_o;
    wire [`INST_LEN] if_cur_inst_o;

    wire [`ADDR_LEN] id_pc_i;
    wire [`INST_LEN] id_inst_i;

    wire jal_jmp;
    wire [`ADDR_LEN] jal_jmp_addr;

    wire ex_jmp;
    wire [`DATA_LEN] ex_jmp_addr_o;

    wire wb_rd_wen;
    wire [`REG_IDX] wb_rd_idx_o;
    wire [`ADDR_LEN] wb_rd_data_o;

    wire [`DATA_LEN] id_rs1_data_o;
    wire [`DATA_LEN] id_rs2_data_o;
    wire [`REG_IDX] id_rs1_idx_o;
    wire [`REG_IDX] id_rs2_idx_o;
    wire [1:0] id_rs1_type_o;
    wire [1:0] id_rs2_type_o;
    wire [`REG_IDX] id_rd_idx_o;
    wire [`DATA_LEN] id_imm_o;
    wire id_wb_o;
    wire id_rmem_o;
    wire id_wmem_o;
    wire [16:0] id_info_o;

    wire [`ADDR_LEN] ex_pc_i;
    wire [`DATA_LEN] ex_imm_i;
    wire [`DATA_LEN] ex_rs1_data_i;
    wire [`DATA_LEN] ex_rs2_data_i;
    wire [`REG_IDX] ex_rs1_idx_i;
    wire [`REG_IDX] ex_rs2_idx_i;
    wire [`REG_IDX] ex_rd_idx_i;
    wire ex_wb_i;
    wire ex_rmem_i;
    wire ex_wmem_i;
    wire [1:0] ex_rs1_type_i;
    wire [1:0] ex_rs2_type_i;
    wire [16:0] ex_info_i;

    wire [`DATA_LEN] ex_result_o;
    wire [`DATA_LEN] ex_wmem_data_o;
    
    wire [`DATA_LEN] fwd_rs1_data;
    wire [`DATA_LEN] fwd_rs2_data;
    wire fwd_rs1_sig;
    wire fwd_rs2_sig;

    wire mem_wmem_i;
    wire mem_rmem_i;
    wire [`ADDR_LEN] mem_result_i;
    wire [`DATA_LEN] mem_wdata_i;
    wire [`DATA_LEN] mem_rdata_o;

    wire mem_wb_i;
    wire [`REG_IDX] wb_rd_idx_i;

    wire [2:0] wmem_info;

    wire [`DATA_LEN] wb_ex_result_i;
    wire [`DATA_LEN] wb_rdata_i;
    wire wb_wmem_i;
    wire wb_rmem_i;

    inst_fetch IFU (
        .clk(clk),
        .rst(rst),
        .jmp(if_jmp_i),
        .hold(hold & hzd_load_hold),
        .jmp_pc_i(if_jmp_pc_i),
        .cur_pc_o(if_cur_pc_o),
        .cur_inst_o(if_cur_inst_o)
    );
    
    if_id IF_ID (
        .clk(clk),
        .rst(rst & hzd_jmp_hold), // jmp nop
        .hold(hold & hzd_load_hold),
        .cur_pc_i(if_cur_pc_o),
        .cur_inst_i(if_cur_inst_o),
        .cur_pc_o(id_pc_i),
        .cur_inst_o(id_inst_i)
    );

    inst_decode IDU (
        .clk(clk),
        .cur_pc_i(id_pc_i),
        .cur_inst_i(id_inst_i),
        .rd_wen(wb_rd_wen),
        .rd_idx_i(wb_rd_idx_o),
        .rd_wdata_i(wb_rd_data_o),
        .jal_jmp(jal_jmp),
        .jal_jmp_addr_o(jal_jmp_addr),
        .imm_o(id_imm_o),
        .rs1_data_o(id_rs1_data_o),
        .rs2_data_o(id_rs2_data_o),
        .rs1_idx_o(id_rs1_idx_o),
        .rs2_idx_o(id_rs2_idx_o),
        .rd_idx_o(id_rd_idx_o),
        .wb(id_wb_o),
        .rmem(id_rmem_o),
        .wmem(id_wmem_o),
        .rs1_type_o(id_rs1_type_o),
        .rs2_type_o(id_rs2_type_o),
        .info_o(id_info_o) 
    );

    id_ex ID_EX (
        .clk(clk),
        .hold(hold),
        .rst(rst & hzd_load_hold & hzd_jmp_hold), // ld jmp nop
        .cur_pc_i(id_pc_i),
        .imm_i(id_imm_o),
        .rs1_data_i(id_rs1_data_o),
        .rs2_data_i(id_rs2_data_o),
        .rs1_idx_i(id_rs1_idx_o),
        .rs2_idx_i(id_rs2_idx_o),
        .rd_idx_i(id_rd_idx_o),
        .wb_i(id_wb_o),
        .rmem_i(id_rmem_o),
        .wmem_i(id_wmem_o),
        .rs1_type_i(id_rs1_type_o),
        .rs2_type_i(id_rs2_type_o),
        .info_i(id_info_o),
        .cur_pc_o(ex_pc_i),
        .imm_o(ex_imm_i),
        .rs1_data_o(ex_rs1_data_i),
        .rs2_data_o(ex_rs2_data_i),
        .rs1_idx_o(ex_rs1_idx_i),
        .rs2_idx_o(ex_rs2_idx_i),
        .rd_idx_o(ex_rd_idx_i),
        .wb_o(ex_wb_i),
        .rmem_o(ex_rmem_i),
        .wmem_o(ex_wmem_i),
        .rs1_type_o(ex_rs1_type_i),
        .rs2_type_o(ex_rs2_type_i),
        .info_o(ex_info_i)
    );

    execute EXU (
        .pc_i(ex_pc_i),
        .imm_i(ex_imm_i),
        .rs1_data_i(ex_rs1_data_i),
        .rs2_data_i(ex_rs2_data_i),
        .rs1_fwd_i(fwd_rs1_data),
        .rs2_fwd_i(fwd_rs2_data),
        .rs1_fwd_sig_i(fwd_rs1_sig),
        .rs2_fwd_sig_i(fwd_rs2_sig),
        .rs1_type_i(ex_rs1_type_i),
        .rs2_type_i(ex_rs2_type_i),
        .info_i(ex_info_i),
        .result_o(ex_result_o),
        .wmem_data_o(ex_wmem_data_o),
        .jmp(ex_jmp),
        .jmp_addr_o(ex_jmp_addr_o)
    );

    ex_mem EX_MEM (
        .clk(clk),
        .hold(hold),
        .rst(rst),
        .funct3_i(ex_info_i[2:0]),
        .rd_idx_i(ex_rd_idx_i),
        .wb_i(ex_wb_i),
        .rmem_i(ex_rmem_i),
        .alu_i(ex_result_o),
        .wmem_data_i(ex_wmem_data_o),
        .wmem_i(ex_wmem_i),
        .funct3_o(wmem_info),
        .rd_idx_o(wb_rd_idx_i),
        .wb_o(mem_wb_i),
        .rmem_o(mem_rmem_i),
        .result_o(mem_result_i),
        .wmem_data_o(mem_wdata_i),
        .wmem_o(mem_wmem_i)
    );

    visit_memory MEMORY (
        .clk(clk),
        .wen(mem_wmem_i),
        .funct3_i(wmem_info),
        .waddr_i(mem_result_i),
        .wdata_i(mem_wdata_i),
        .raddr_i(mem_result_i),
        .rdata_o(mem_rdata_o)
    );

    mem_wb MEM_WB (
        .clk(clk),
        .hold(hold),
        .rst(rst),
        .raddr_i(mem_rdata_o),
        .result_i(mem_result_i),
        .rd_idx_i(wb_rd_idx_i),
        .wb_i(mem_wb_i),
        .wmem_i(mem_wmem_i),
        .rmem_i(mem_rmem_i),
        .raddr_o(wb_rdata_i),
        .result_o(wb_ex_result_i),
        .rd_idx_o(wb_rd_idx_o),
        .wb_o(wb_rd_wen),
        .wmem_o(wb_wmem_i),
        .rmem_o(wb_rmem_i)
    );

    write_back WB (
        .wmem(wb_wmem_i),
        .rmem(wb_rmem_i),
        .result_i(wb_ex_result_i),
        .rdata_i(wb_rdata_i),
        .rd_wdata_o(wb_rd_data_o)
    );

    forwarding FORWARDING (
        .wb_pipe_sig(mem_wb_i),
        .rd_idx_pipe_i(wb_rd_idx_i),
        .rd_pipe_data_i(mem_result_i),
        .wb_final_sig(wb_rmem_i),
        .rd_idx_final_i(wb_rd_idx_o),
        .rd_final_data_i(wb_rdata_i),
        .rs1_idx_i(ex_rs1_idx_i),
        .rs2_idx_i(ex_rs2_idx_i),
        .cur_rs1_type_i(ex_rs1_type_i),
        .cur_rs2_type_i(ex_rs2_type_i),
        .rs1_fwd_sig(fwd_rs1_sig),
        .rs2_fwd_sig(fwd_rs2_sig),
        .rs1_fwd_data_o(fwd_rs1_data),
        .rs2_fwd_data_o(fwd_rs2_data)
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
        .former_opcode(ex_info_i[16:10]),
        .former_inst_rd_i(ex_rd_idx_i),
        .jmp(if_jmp_i),
        .ld_hold(hzd_load_hold),
        .jmp_hold(hzd_jmp_hold),
        .jmp_addr_o(if_jmp_pc_i)
    );

    // // dbg if
    // assign dbg_if_pc_o = if_cur_pc_o;
    // assign dbg_if_inst_o = if_cur_inst_o;
    // assign dbg_if_jmp_pc_o = if_jmp_pc_i;
    
    // // dbg id
    // assign dbg_id_rs1_idx = id_rs1_idx_o;
    // assign dbg_id_rs2_idx = id_rs2_idx_o;
    // assign dbg_id_rd_idx = id_rd_idx_o;
    // assign dbg_id_rs1 = id_rs1_data_o;
    // assign dbg_id_rs2 = id_rs2_data_o;
    // assign dbg_id_imm_o = id_imm_o;
    // assign dbg_id_op1_sel = id_rs1_type_o;
    // assign dbg_id_op2_sel = id_rs2_type_o;
    // assign {dbg_id_opcode, dbg_id_funct7, dbg_id_funct3} = id_info_o;
    // assign dbg_id_wb = id_wb_o;
    // assign dbg_id_rmem = id_rmem_o;
    // assign dbg_id_wmem = id_wmem_o;
    

    // // dbg exec
    // assign dbg_ex_result_o = ex_result_o;
    // assign dbg_ex_latter_jmp = ex_jmp;

    // // dbg mem
    // assign dbg_mem_rmem_o = mem_rdata_o;

    // // dbg wb
    // assign dbg_wb_rd_data_o = wb_rd_data_o;

    // // dbg fwd
    // assign dbg_fwd_op1_sig = fwd_rs1_sig;
    // assign dbg_fwd_op2_sig = fwd_rs2_sig;
    // assign dbg_fwd_op1_data = fwd_rs1_data;
    // assign dbg_fwd_op2_data = fwd_rs2_data;

    // // dbg hzd
    // assign dbg_hzd_jmp = hzd_jmp_hold;
    // assign dbg_hzd_ld = hzd_load_hold;
endmodule
