`define WIDTH64 63:0
`define WIDTH32 31:0
`define WIDTH16 15:0
`define WIDTH8   7:0
`define WIDTH4   3:0
`define WIDTH2   1:0

`define REG_IDX 4:0

`define INST_LEN 31:0
`define ADDR_LEN 63:0
`define REG_LEN  63:0
`define DATA_LEN 63:0

`define INST_SZ  32

`define N_TYPE  8'b00000001
`define R_TYPE  8'b00000010
`define I_TYPE  8'b00000100
`define S_TYPE  8'b00001000
`define B_TYPE  8'b00010000
`define U_TYPE  8'b00100000
`define J_TYPE  8'b01000000
`define R4_TYPE 8'b10000000

`define OP_LOAD         7'b00_000_11
`define OP_LOAD_FP      7'b00_001_11
`define OP_C_0          7'b00_010_11
`define OP_MISC_MEM     7'b00_011_11
`define OP_OP_IMM       7'b00_100_11
`define OP_AUIPC        7'b00_101_11
`define OP_OP_IMM_32    7'b00_110_11
`define OP_48b          7'b00_111_11
`define OP_STORE        7'b01_000_11
`define OP_STORE_FP     7'b01_001_11
`define OP_C_1          7'b01_010_11
`define OP_AMO          7'b01_011_11
`define OP_OP           7'b01_100_11
`define OP_LUI          7'b01_101_11
`define OP_OP_32        7'b01_110_11
`define OP_64b          7'b01_111_11
`define OP_MADD         7'b10_000_11
`define OP_MSUB         7'b10_001_11
`define OP_NMSUB        7'b10_010_11
`define OP_NMADD        7'b10_011_11
`define OP_OP_FP        7'b10_100_11
`define OP_rsv0         7'b10_101_11
`define OP_C_2_rv128    7'b10_110_11
`define OP_48b_1        7'b10_111_11
`define OP_BRANCH       7'b11_000_11
`define OP_JALR         7'b11_001_11
`define OP_rsv1         7'b11_010_11
`define OP_JAL          7'b11_011_11
`define OP_SYSTEM       7'b11_100_11
`define OP_rsv2         7'b11_101_11
`define OP_C_3_rv128    7'b11_110_11
`define OP_48b_2        7'b11_111_11

`define FUNCT3_ADD  3'b000
`define FUNCT3_SLL  3'b001
`define FUNCT3_SLT  3'b010
`define FUNCT3_SLTU 3'b011
`define FUNCT3_XOR  3'b100
`define FUNCT3_SRL  3'b101
`define FUNCT3_OR   3'b110
`define FUNCT3_AND  3'b111

`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111

`define FUNCT7_RAW  7'b0000000
`define FUNCT7_ALT  7'b0100000

`define NOP_INST 32'b000000000000_00000_000_00000_0010011

`define ENABLE  1'b0
`define DISABLE 1'b1

`define RS_RAW 2'b00
`define RS_FWD 2'b01
`define RS_PC  2'b10
`define RS_IMM 2'b11

`define SEL_BYTE 3'b000
`define SEL_HALF 3'b001
`define SEL_WORD 3'b010
`define SEL_BYTU 3'b100
`define SEL_HLFU 3'b101
`define SEL_WRDU 3'b110
`define SEL_DWRD 3'b011
