`timescale 1ns / 1ps

`include "defines.v"

module write_back (
    input visit,
    input wmem_en,
    input [`DATA_LEN] result_i,
    input [`DATA_LEN] rdata_i,
    output [`DATA_LEN] rd_wdata_o
);
    Mux2 ld_or_res (
        .select(!visit && wmem_en),
        .hi_i(rdata_i),
        .lo_i(result_i),
        .data_o(rd_wdata_o)
    );
endmodule
