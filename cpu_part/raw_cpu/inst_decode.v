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
    output visit,
    output [1:0] rs1_type_o,
    output [1:0] rs2_type_o,
    output [16:0] exec_o
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

    assign exec_o = {opcode, funct7, funct3};


//    Muxplexer #(
//        .NR_KEY(11),
//        .KEY_LEN(7),
//        .DATA_LEN(12),
//        .HAS_DEFAULT(1'b1)
//    ) mux_type (
//        .data_o({inst_type, rs1_type_o, rs2_type_o}),
//        .key_i(opcode),
//        .default_i({`N_TYPE, `RS_IMM, `RS_IMM}),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `OP_LUI,        {`U_TYPE, `RS_IMM, `RS_IMM},
//            `OP_AUIPC,      {`U_TYPE,  `RS_PC, `RS_IMM},
//            `OP_JAL,        {`J_TYPE,  `RS_PC,  `RS_PC},
//            `OP_JALR,       {`I_TYPE,  `RS_PC,  `RS_PC},
//            `OP_BRANCH,     {`B_TYPE, `RS_IMM, `RS_IMM},
//            `OP_LOAD,       {`I_TYPE, `RS_RAW, `RS_IMM},
//            `OP_STORE,      {`S_TYPE, `RS_RAW, `RS_IMM},
//            `OP_OP_IMM,     {`I_TYPE, `RS_RAW, `RS_IMM},
//            `OP_OP,         {`R_TYPE, `RS_RAW, `RS_RAW},
//            `OP_MISC_MEM,   {`I_TYPE, `RS_IMM, `RS_IMM},
//            `OP_SYSTEM,     {`N_TYPE, `RS_IMM, `RS_IMM}
//        })
//    );

    assign {inst_type, rs1_type_o, rs2_type_o} = 
                   ~|{opcode ^ `OP_LUI     } ? {`U_TYPE, `RS_IMM, `RS_IMM} :
                   ~|{opcode ^ `OP_AUIPC   } ? {`U_TYPE,  `RS_PC, `RS_IMM} :
                   ~|{opcode ^ `OP_JAL     } ? {`J_TYPE,  `RS_PC,  `RS_PC} :
                   ~|{opcode ^ `OP_JALR    } ? {`I_TYPE,  `RS_PC,  `RS_PC} :
                   ~|{opcode ^ `OP_BRANCH  } ? {`B_TYPE, `RS_IMM, `RS_IMM} :
                   ~|{opcode ^ `OP_LOAD    } ? {`I_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_STORE   } ? {`S_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_OP_IMM  } ? {`I_TYPE, `RS_RAW, `RS_IMM} :
                   ~|{opcode ^ `OP_OP      } ? {`R_TYPE, `RS_RAW, `RS_RAW} :
                   ~|{opcode ^ `OP_MISC_MEM} ? {`I_TYPE, `RS_IMM, `RS_IMM} :
                   ~|{opcode ^ `OP_SYSTEM  } ? {`N_TYPE, `RS_IMM, `RS_IMM} :
                   {`N_TYPE, `RS_IMM, `RS_IMM};
                   
//    Muxplexer #(
//        .NR_KEY(2),
//        .KEY_LEN(7),
//        .DATA_LEN(1),
//        .HAS_DEFAULT(1'b1)
//    ) mux_visit (
//        .data_o(visit),
//        .key_i(opcode),
//        .default_i(`DISABLE),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `OP_LOAD,   `ENABLE,
//            `OP_STORE,  `ENABLE
//        })
//    );
    
    
    assign visit = ~|{opcode ^ `OP_LOAD } ? `ENABLE :
                   ~|{opcode ^ `OP_STORE} ? `ENABLE :
                   `DISABLE;
                
                
//    Muxplexer #(
//        .NR_KEY(4),
//        .KEY_LEN(8),
//        .DATA_LEN(1),
//        .HAS_DEFAULT(1'b1)
//    ) mux_wb (
//        .data_o(wb),
//        .key_i(inst_type),
//        .default_i(`DISABLE),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `R_TYPE, `ENABLE,
//            `I_TYPE, `ENABLE,
//            `U_TYPE, `ENABLE,
//            `J_TYPE, `ENABLE
//        })
//    );
    
    assign wb = ~|{inst_type ^ `R_TYPE} ? `ENABLE :
                ~|{inst_type ^ `I_TYPE} ? `ENABLE :
                ~|{inst_type ^ `U_TYPE} ? `ENABLE :
                ~|{inst_type ^ `J_TYPE} ? `ENABLE :
                `DISABLE;

//    Muxplexer #(
//        .NR_KEY(5),
//        .KEY_LEN(8),
//        .DATA_LEN(64),
//        .HAS_DEFAULT(1'b1)
//    ) mux_imm (
//        .data_o(imm_o),
//        .key_i(inst_type),
//        .default_i({64{1'b0}}),
//        .lut_i({
//            // RV32I Base Instruct Set
//            `I_TYPE, immI,
//            `S_TYPE, immS,
//            `B_TYPE, immB,
//            `U_TYPE, immU,
//            `J_TYPE, immJ
//        })
//    );
    
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
