`timescale 1ns / 1ps

`include "defines.v"

module execute (
    input [`ADDR_LEN] cur_pc_i,

    input [`DATA_LEN] imm_i,

    input [`DATA_LEN] rs1_data_i,
    input [`DATA_LEN] rs2_data_i,

    input [`DATA_LEN] rs1_fwd_i,
    input [`DATA_LEN] rs2_fwd_i,

    input rs1_fwd_sig_i,
    input rs2_fwd_sig_i,
    input [1:0] rs1_type_i,
    input [1:0] rs2_type_i,
    input [16:0] exec_i,

    output [`DATA_LEN] result_o,
    output [`DATA_LEN] wmem_data_o,
    output wmem_en,

    output jmp,
    output [`DATA_LEN] jmp_addr_o
);


    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    assign {opcode, funct7, funct3} = exec_i;

    assign jmp_addr_o = cur_pc_i + imm_i;

    assign wmem_data_o = rs2_data_i;
    assign wmem_en = |(opcode ^ `OP_STORE);
    
    wire [1:0] rs1_sel;
    wire [1:0] rs2_sel;

    wire [`DATA_LEN] op1;
    wire [`DATA_LEN] op2;

    assign rs1_sel = !rs1_fwd_sig_i ? `RS_FWD : rs1_type_i;
    assign rs2_sel = !rs2_fwd_sig_i ? `RS_FWD : rs2_type_i;
    
//    Mux2 #(2) iffwd1 (
//        .select(!rs1_fwd_sig_i),
//        .hi_i(`RS_FWD),
//        .lo_i(rs1_type_i),
//        .data_o(rs1_sel)
//    );

//    Mux2 #(2) iffwd2 (
//        .select(!rs2_fwd_sig_i),
//        .hi_i(`RS_FWD),
//        .lo_i(rs2_type_i),
//        .data_o(rs2_sel)
//    );

    assign op1 =    ~|{rs1_sel ^ `RS_RAW} ? rs1_data_i :
                    ~|{rs1_sel ^ `RS_FWD} ? rs1_fwd_i  :
                    ~|{rs1_sel ^ `RS_PC } ? cur_pc_i   :
                    ~|{rs1_sel ^ `RS_IMM} ? imm_i      :
                    64'b0;

    assign op2 =    ~|{rs2_sel ^ `RS_RAW} ? rs2_data_i :
                    ~|{rs2_sel ^ `RS_FWD} ? rs2_fwd_i  :
                    ~|{rs2_sel ^ `RS_PC } ? 64'd4      :
                    ~|{rs2_sel ^ `RS_IMM} ? imm_i      :
                    64'b0;

//    Muxplexer #(
//        .NR_KEY(4),
//        .KEY_LEN(2),
//        .DATA_LEN(64)
//    ) mux_rs1 (
//        .data_o(op1),
//        .key_i(rs1_sel),
//        .default_i(64'b0),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `RS_RAW, rs1_data_i,
//            `RS_FWD, rs1_fwd_i,
//            `RS_PC,  cur_pc_i,
//            `RS_IMM, imm_i
//        })
//    );

//    Muxplexer #(
//        .NR_KEY(4),
//        .KEY_LEN(2),
//        .DATA_LEN(64)
//    ) mux_rs2 (
//        .data_o(op2),
//        .key_i(rs2_sel),
//        .default_i(64'b0),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `RS_RAW, rs2_data_i,
//            `RS_FWD, rs2_fwd_i,
//            `RS_PC,  64'd4,
//            `RS_IMM, imm_i
//        })
//    );

    wire [`DATA_LEN] add_res;
    assign add_res = (opcode == `OP_OP && funct7 == `FUNCT7_ALT) ? op1 - op2 : op1 + op2;

    wire [`DATA_LEN] and_res;
    assign and_res = op1 & op2;

    wire [`DATA_LEN] or_res;
    assign or_res = op1 | op2;

    wire [`DATA_LEN] xor_res;
    assign xor_res = op1 ^ op2;

    wire [`DATA_LEN] slt_res;
    assign slt_res = op1[63] > op2[63] ? 64'b1 :
        (op1[63] == 1 && {~op1 + 1} > {~op2 + 1}) ?  64'b1 :
        (op1[63] == 0 && {~op1 + 1} < {~op2 + 1}) ?  64'b1 : 64'b0;

    wire [`DATA_LEN] sltu_res;
    assign sltu_res = op1 < op2 ? 64'b1 : 64'b0;

    wire [`DATA_LEN] sll_res;
    assign sll_res = op1 << op2;

    wire [`DATA_LEN] srl_res;
    assign srl_res = op1 >> op2;

    wire [`DATA_LEN] sra_res;
    wire [`DATA_LEN] sra_stage_1;
    wire [`DATA_LEN] sra_stage_2;
    wire [`DATA_LEN] sra_stage_3;
    wire [`DATA_LEN] sra_stage_4;
    wire [`DATA_LEN] sra_stage_5;
    assign sra_stage_1 = |(op2 & 64'b000001) ? {op1[63], op1[63:1]} : op1;
    assign sra_stage_2 = |(op2 & 64'b000010) ? {{2{sra_stage_1[63]}}, sra_stage_1[63:2]} : sra_stage_1;
    assign sra_stage_3 = |(op2 & 64'b000100) ? {{4{sra_stage_2[63]}}, sra_stage_2[63:4]} : sra_stage_2;
    assign sra_stage_4 = |(op2 & 64'b001000) ? {{8{sra_stage_3[63]}}, sra_stage_3[63:8]} : sra_stage_3;
    assign sra_stage_5 = |(op2 & 64'b010000) ? {{16{sra_stage_4[63]}}, sra_stage_4[63:16]} : sra_stage_4;
    assign sra_res     = |(op2 & 64'b100000) ? {{32{sra_stage_5[63]}}, sra_stage_5[63:32]} : sra_stage_5;

    wire [`DATA_LEN] sr_res;
    assign sr_res = funct7 == `FUNCT7_ALT ? sra_res : srl_res;

    wire [`DATA_LEN] op_res;

    assign op_res = ~|{funct3 ^ `FUNCT3_ADD } ? add_res :
                    ~|{funct3 ^ `FUNCT3_OR  } ? or_res  :
                    ~|{funct3 ^ `FUNCT3_SLL } ? sll_res :
                    ~|{funct3 ^ `FUNCT3_SLT } ? slt_res :
                    ~|{funct3 ^ `FUNCT3_SLTU} ? sltu_res:
                    ~|{funct3 ^ `FUNCT3_SRL } ? sr_res  :
                    ~|{funct3 ^ `FUNCT3_XOR } ? xor_res :
                    ~|{funct3 ^ `FUNCT3_AND } ? and_res :
                    64'b0;

//    Muxplexer #(
//        .NR_KEY(8),
//        .KEY_LEN(3),
//        .DATA_LEN(64),
//        .HAS_DEFAULT(1'b1)
//    ) mux_op_res (
//        .data_o(op_res),
//        .key_i(funct3),
//        .default_i(64'b0),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `FUNCT3_ADD,  add_res,
//            `FUNCT3_OR,   or_res,
//            `FUNCT3_SLL,  sll_res,
//            `FUNCT3_SLT,  slt_res,
//            `FUNCT3_SLTU, sltu_res,
//            `FUNCT3_SRL,  sr_res,
//            `FUNCT3_XOR,  xor_res,
//            `FUNCT3_AND,  and_res
//        })
//    );

    assign jmp  =   ~|{funct3 ^ `FUNCT3_BEQ } ?  |xor_res :
                    ~|{funct3 ^ `FUNCT3_BNE } ? ~|xor_res :
                    ~|{funct3 ^ `FUNCT3_BLT } ? ~|slt_res :
                    ~|{funct3 ^ `FUNCT3_BGE } ?  |slt_res :
                    ~|{funct3 ^ `FUNCT3_BLTU} ? ~|sltu_res:
                    ~|{funct3 ^ `FUNCT3_BGEU} ?  |sltu_res:
                    1'b0;

//    Muxplexer #(
//        .NR_KEY(6),
//        .KEY_LEN(3),
//        .DATA_LEN(1),
//        .HAS_DEFAULT(1'b1)
//    ) mux_jmp_res (
//        .data_o(jmp),
//        .key_i(funct3),
//        .default_i(1'b0),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `FUNCT3_BEQ,  |xor_res,
//            `FUNCT3_BNE,  ~|xor_res,
//            `FUNCT3_BLT,  ~|slt_res,
//            `FUNCT3_BGE,  |slt_res,
//            `FUNCT3_BLTU, ~|sltu_res,
//            `FUNCT3_BGEU, |sltu_res
//        })
//    );

    assign result_o =   ~|{opcode ^ `OP_LUI     } ? imm_i  :
                        ~|{opcode ^ `OP_AUIPC   } ? add_res:
                        ~|{opcode ^ `OP_JAL     } ? add_res:
                        ~|{opcode ^ `OP_JALR    } ? add_res:
                        ~|{opcode ^ `OP_BRANCH  } ? imm_i  :
                        ~|{opcode ^ `OP_LOAD    } ? add_res:
                        ~|{opcode ^ `OP_STORE   } ? add_res:
                        ~|{opcode ^ `OP_OP_IMM  } ? op_res :
                        ~|{opcode ^ `OP_OP      } ? op_res :
                        ~|{opcode ^ `OP_MISC_MEM} ? imm_i  :
                        ~|{opcode ^ `OP_SYSTEM  } ? imm_i  :
                        64'b0;

//    Muxplexer #(
//        .NR_KEY(11),
//        .KEY_LEN(7),
//        .DATA_LEN(64),
//        .HAS_DEFAULT(1'b1)
//    ) mux_result (
//        .data_o(result_o),
//        .key_i(opcode),
//        .default_i(64'b0),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `OP_LUI,        imm_i,
//            `OP_AUIPC,      add_res,
//            `OP_JAL,        add_res,
//            `OP_JALR,       add_res,
//            `OP_BRANCH,     imm_i,
//            `OP_LOAD,       add_res,
//            `OP_STORE,      add_res,
//            `OP_OP_IMM,     op_res,
//            `OP_OP,         op_res,
//            `OP_MISC_MEM,   imm_i,
//            `OP_SYSTEM,     imm_i
//        })
//    );
endmodule
