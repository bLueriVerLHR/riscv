`timescale 1ns / 1ps

// copy from ysyx template

`include "defines.v"

module Register #(
    WIDTH = 64,
    RESET_VAL = 64'h0
) (
    input clk,
    input rst,
    input wen,
    input [WIDTH-1:0] data_i,
    output reg [WIDTH-1:0] data_o
);
    always @(posedge clk) begin
        if (!rst) begin
            data_o <= RESET_VAL;
        end
        else if (!wen) begin
            data_o <= data_i;
        end
        else begin
            data_o <= data_o;
        end
    end

endmodule
