`timescale 1ns / 1ps

`include "defines.v"

module Memory (
    input clk,
    input wen,
    input [2:0] funct3_i,
    input [`ADDR_LEN] waddr_i,
    input [`DATA_LEN] wdata_i,
    input [`ADDR_LEN] raddr_i,
    output [`DATA_LEN] rdata_o
);
    reg [`DATA_LEN] mem [4096:0];

    always @(posedge clk) begin
        if (!wen) begin
            case (funct3_i)
                `SEL_BYTE: mem[waddr_i][ `WIDTH8] <= wdata_i[ `WIDTH8];
                `SEL_HALF: mem[waddr_i][`WIDTH16] <= wdata_i[`WIDTH16];
                `SEL_WORD: mem[waddr_i][`WIDTH32] <= wdata_i[`WIDTH32];
                `SEL_DWRD: mem[waddr_i][`WIDTH64] <= wdata_i[`WIDTH64];
                default:   mem[waddr_i][`WIDTH64] <= wdata_i[`WIDTH64];
            endcase
        end
    end

    assign rdata_o = {64{~|{`SEL_DWRD ^ funct3_i}}} & mem[raddr_i] | 
            {64{~|{`SEL_WORD ^ funct3_i}}} & {{32{wdata_i[31]}}, mem[raddr_i][`WIDTH32]} | 
            {64{~|{`SEL_HALF ^ funct3_i}}} & {{48{wdata_i[15]}}, mem[raddr_i][`WIDTH16]} | 
            {64{~|{`SEL_BYTE ^ funct3_i}}} & {{56{wdata_i[ 7]}}, mem[raddr_i][ `WIDTH8]} |
            {64{~|{`SEL_WRDU ^ funct3_i}}} & {{32{       1'b0}}, mem[raddr_i][`WIDTH32]} | 
            {64{~|{`SEL_HLFU ^ funct3_i}}} & {{48{       1'b0}}, mem[raddr_i][`WIDTH16]} | 
            {64{~|{`SEL_BYTU ^ funct3_i}}} & {{56{       1'b0}}, mem[raddr_i][ `WIDTH8]};

endmodule
