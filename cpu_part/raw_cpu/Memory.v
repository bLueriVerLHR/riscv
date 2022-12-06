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
    parameter MEM_SIZE = 4096;
    
    reg [`DATA_LEN] mem [MEM_SIZE-1:0];

    always @(posedge clk) begin
        if (!wen) begin
            case (funct3_i)
                `SEL_BYTE: mem[waddr_i][`WIDTH8 ] <= wdata_i[`WIDTH8 ];
                `SEL_HALF: mem[waddr_i][`WIDTH16] <= wdata_i[`WIDTH16];
                `SEL_WORD: mem[waddr_i][`WIDTH32] <= wdata_i[`WIDTH32];
                `SEL_DWRD: mem[waddr_i][`WIDTH64] <= wdata_i[`WIDTH64];
                default:   mem[waddr_i][`WIDTH64] <= wdata_i[`WIDTH64];
            endcase
        end
    end
    
    wire hazard_sig;
    wire [`DATA_LEN] hazard;
    assign hazard_sig = !wen & ~|{waddr_i ^ raddr_i};
    assign hazard = {64{hazard_sig}} & wdata_i |  ~{64{hazard_sig}} &  mem[raddr_i];

    assign rdata_o = {64{~|{`SEL_DWRD ^ funct3_i}}} & hazard | 
            {64{~|{`SEL_WORD ^ funct3_i}}} & {{32{hazard[31]}},  hazard[`WIDTH32]} | 
            {64{~|{`SEL_HALF ^ funct3_i}}} & {{48{hazard[15]}},  hazard[`WIDTH16]} | 
            {64{~|{`SEL_BYTE ^ funct3_i}}} & {{56{hazard[ 7]}},  hazard[`WIDTH8 ]} |
            {64{~|{`SEL_WRDU ^ funct3_i}}} & {{32{       1'b0}}, hazard[`WIDTH32]} | 
            {64{~|{`SEL_HLFU ^ funct3_i}}} & {{48{       1'b0}}, hazard[`WIDTH16]} | 
            {64{~|{`SEL_BYTU ^ funct3_i}}} & {{56{       1'b0}}, hazard[`WIDTH8 ]};
            
    initial begin: init_mem
        integer i;
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 64'b0;
        end
    end

endmodule
