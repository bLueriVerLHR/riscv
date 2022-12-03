`timescale 1ns / 1ps

module Mux2 #(
    WIDTH = 64
) (
    input select,
    input [WIDTH-1:0] hi_i,
    input [WIDTH-1:0] lo_i,
    output  [WIDTH-1:0] data_o
);

    assign data_o = select ? hi_i : lo_i;    
endmodule
