`timescale 1ns / 1ps

`include "defines.v"

module write_back (
    input wmem,
    input rmem,
    input [`DATA_LEN] result_i,
    input [`DATA_LEN] rdata_i,
    output [`DATA_LEN] rd_wdata_o
);
    assign rd_wdata_o = !wmem && rmem ? rdata_i : result_i;
    
endmodule
