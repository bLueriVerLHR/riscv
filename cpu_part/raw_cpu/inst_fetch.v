`timescale 1ns / 1ps

`include "defines.v"

module inst_fetch (
    input  clk,
    input  rst,
    input  jmp,
    input  hold,
    input  [`ADDR_LEN] jmp_pc_i,
    output [`ADDR_LEN] cur_pc_o,
    output [`INST_LEN] cur_inst_o
);

    wire [`ADDR_LEN] default_next_pc;
    wire [`ADDR_LEN] pc_output;
    wire [`ADDR_LEN] next_pc;

    assign cur_pc_o = pc_output;
    assign default_next_pc = pc_output + 4;

    Mux2 mux_pc_in (
        .select(!jmp),
        .hi_i(jmp_pc_i),
        .lo_i(default_next_pc),
        .data_o(next_pc)
    );

    Register pc (
        .clk(clk),
        .rst(rst),
        .wen(!hold),
        .data_i(next_pc),
        .data_o(pc_output)
    );

    Inst_Memory instructions (
        .clk(clk),
        .wen(1'b1),
        .waddr_i(64'b0),
        .wdata_i(32'b0),
        .raddr_i(pc_output),
        .rdata_o(cur_inst_o)
    );
    
endmodule
