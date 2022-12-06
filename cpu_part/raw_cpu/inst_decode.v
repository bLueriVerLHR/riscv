`timescale 1ns / 1ps

`include "defines.v"

module inst_decode (
    input  clk,

    input [`ADDR_LEN] cur_pc_i,
    input [`INST_LEN] cur_inst_i,

    input  rd_wen,
    input  [`REG_IDX] rd_idx_i,
    input  [`DATA_LEN] rd_wdata_i,

    // output [7:0] inst_type_o,
    output [`ADDR_LEN] jal_jmp_addr_o,
    output jal_jmp,

    output [`DATA_LEN] imm_o,

    output [`DATA_LEN] rs1_data_o,
    output [`DATA_LEN] rs2_data_o,

    output [`REG_IDX] rs1_idx_o,
    output [`REG_IDX] rs2_idx_o,
    output [`REG_IDX] rd_idx_o,

    output wb,
    output rmem,
    output wmem,
    output [1:0] rs1_type_o,
    output [1:0] rs2_type_o,
    output [16:0] info_o
);
    wire [7:0] inst_type;

    wire [6:0] opcode;
    assign opcode = cur_inst_i[6:0];

    assign rd_idx_o  = cur_inst_i[11: 7];
    assign rs1_idx_o = cur_inst_i[19:15];
    assign rs2_idx_o = cur_inst_i[24:20];

    wire [2:0] funct3;
    wire [6:0] funct7;
    assign funct3 = cur_inst_i[14:12];
    assign funct7 = cur_inst_i[31:25];

    wire [`REG_LEN] immI;
    wire [`REG_LEN] immS;
    wire [`REG_LEN] immB;
    wire [`REG_LEN] immU;
    wire [`REG_LEN] immJ;
    
    assign immI = {{52{cur_inst_i[31]}}, cur_inst_i[31:20]};
    assign immS = {{52{cur_inst_i[31]}}, cur_inst_i[31:25], cur_inst_i[11: 7]};
    assign immB = {{51{cur_inst_i[31]}}, cur_inst_i[31], cur_inst_i[7], cur_inst_i[30:25], cur_inst_i[11: 8], 1'b0};
    assign immU = {cur_inst_i[31:12], {44{1'b0}}};
    assign immJ = {{43{cur_inst_i[31]}}, cur_inst_i[31], cur_inst_i[19:12], cur_inst_i[20], cur_inst_i[30:21], 1'b0};

    assign jal_jmp = ~|{opcode ^ `OP_JAL} ? `ENABLE : `DISABLE;
    assign jal_jmp_addr_o = immJ + cur_pc_i;

    assign info_o = {opcode, funct7, funct3};

    assign {inst_type, rs1_type_o, rs2_type_o} = 
                   ~|{opcode ^ `OP_LUI     } ? {`U_TYPE, `RS_IMM, `RS_IMM} :
                   ~|{opcode ^ `OP_AUIPC   } ? {`U_TYPE,  `RS_PC, `RS_IMM} :
                   ~|{opcode ^ `OP_JAL     } ? {`J_TYPE,  `RS_PC,  `RS_PC} :
                   ~|{opcode ^ `OP_JALR    } ? {`I_TYPE,  `RS_PC,  `RS_PC} :
                   ~|{opcode ^ `OP_BRANCH  } ? {`B_TYPE, `RS_RAW, `RS_RAW} :
                   ~|{opcode ^ `OP_LOAD    } ? {`I_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_STORE   } ? {`S_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_OP_IMM  } ? {`I_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_OP      } ? {`R_TYPE, `RS_RAW, `RS_RAW} :
                   ~|{opcode ^ `OP_MISC_MEM} ? {`I_TYPE, `RS_IMM, `RS_IMM} :
                   ~|{opcode ^ `OP_SYSTEM  } ? {`N_TYPE, `RS_IMM, `RS_IMM} :
                   {`N_TYPE, `RS_IMM, `RS_IMM};
    
    assign rmem = |{opcode ^ `OP_LOAD };

    assign wmem = |(opcode ^ `OP_STORE);
    
    assign wb = ~|{inst_type ^ `R_TYPE} ? `ENABLE :
                ~|{inst_type ^ `I_TYPE} ? `ENABLE :
                ~|{inst_type ^ `U_TYPE} ? `ENABLE :
                ~|{inst_type ^ `J_TYPE} ? `ENABLE :
                `DISABLE;
    
    assign imm_o = ~|{inst_type ^ `I_TYPE} ? immI :
                   ~|{inst_type ^ `S_TYPE} ? immS :
                   ~|{inst_type ^ `B_TYPE} ? immB :
                   ~|{inst_type ^ `U_TYPE} ? immU :
                   ~|{inst_type ^ `J_TYPE} ? immJ :
                   {64{1'b0}};

    Regs regs (
        .clk(clk),
        .wen(rd_wen),
        .rd_idx_i(rd_idx_i),
        .rd_wdata_i(rd_wdata_i),
        .rs1_idx_i(rs1_idx_o),
        .rs2_idx_i(rs2_idx_o),
        .rs1_data_o(rs1_data_o),
        .rs2_data_o(rs2_data_o)
    );
endmodule
