`timescale 1ns / 1ps

`include "defines.v"

module execute (
    input [`ADDR_LEN] pc_i,

    input [`DATA_LEN] imm_i,

    input [`DATA_LEN] rs1_data_i,
    input [`DATA_LEN] rs2_data_i,

    input [`DATA_LEN] rs1_fwd_i,
    input [`DATA_LEN] rs2_fwd_i,

    input rs1_fwd_sig_i,
    input rs2_fwd_sig_i,
    input [1:0] rs1_type_i,
    input [1:0] rs2_type_i,
    input [16:0] info_i,

    output [`DATA_LEN] result_o,
    output [`DATA_LEN] wmem_data_o,
    output jmp,
    output [`DATA_LEN] jmp_addr_o
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    assign {opcode, funct7, funct3} = info_i;

    assign jmp_addr_o = pc_i + imm_i;

    assign wmem_data_o = rs2_data_i;
    
    wire [1:0] rs1_sel;
    wire [1:0] rs2_sel;

    wire [`DATA_LEN] op1;
    wire [`DATA_LEN] op2;

    assign rs1_sel = !rs1_fwd_sig_i ? `RS_FWD : rs1_type_i;
    assign rs2_sel = !rs2_fwd_sig_i ? `RS_FWD : rs2_type_i;

    assign op1 =    ({64{~|{rs1_sel ^ `RS_RAW}}} & rs1_data_i) |
                    ({64{~|{rs1_sel ^ `RS_FWD}}} & rs1_fwd_i ) |
                    ({64{~|{rs1_sel ^ `RS_PC }}} & pc_i      ) |
                    ({64{~|{rs1_sel ^ `RS_IMM}}} & imm_i     ) ;

    assign op2 =    ({64{~|{rs2_sel ^ `RS_RAW}}} & rs2_data_i) |
                    ({64{~|{rs2_sel ^ `RS_FWD}}} & rs2_fwd_i ) |
                    ({64{~|{rs2_sel ^ `RS_PC }}} & 64'd4     ) |
                    ({64{~|{rs2_sel ^ `RS_IMM}}} & imm_i     ) ;

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

    assign op_res = ({64{~|{funct3 ^ `FUNCT3_ADD }}} & add_res ) |
                    ({64{~|{funct3 ^ `FUNCT3_OR  }}} & or_res  ) |
                    ({64{~|{funct3 ^ `FUNCT3_SLL }}} & sll_res ) |
                    ({64{~|{funct3 ^ `FUNCT3_SLT }}} & slt_res ) |
                    ({64{~|{funct3 ^ `FUNCT3_SLTU}}} & sltu_res) |
                    ({64{~|{funct3 ^ `FUNCT3_SRL }}} & sr_res  ) |
                    ({64{~|{funct3 ^ `FUNCT3_XOR }}} & xor_res ) |
                    ({64{~|{funct3 ^ `FUNCT3_AND }}} & and_res ) ;

    wire is_bnh, en_jmp, is_jalr;

    assign is_jalr = ~|{opcode ^ `OP_JALR };
    assign is_bnh  = ~|{opcode ^ `OP_BRANCH };
    assign en_jmp = ~|{funct3 ^ `FUNCT3_BEQ } ?  |xor_res :
                    ~|{funct3 ^ `FUNCT3_BNE } ? ~|xor_res :
                    ~|{funct3 ^ `FUNCT3_BLT } ? ~|slt_res :
                    ~|{funct3 ^ `FUNCT3_BGE } ?  |slt_res :
                    ~|{funct3 ^ `FUNCT3_BLTU} ? ~|sltu_res:
                    ~|{funct3 ^ `FUNCT3_BGEU} ?  |sltu_res:
                    `DISABLE;
                       
    assign jmp = is_jalr ? `ENABLE:
                 is_bnh  ? en_jmp :
                 `DISABLE;

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
endmodule
