`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ROM_Bg
#(
    parameter color_idxs = "color_idx_pixels.mem",
    parameter colors = "colors.mem"
)(
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] bg_rgb
);
    (* rom_style="block" *) reg [5-1:0] mem [(2**19)-1:0];
    (* rom_style="block" *) reg [12-1:0] mem2 [(2**5)-1:0];
    
    initial $readmemb(color_idxs, mem);
    initial $readmemb(colors, mem2);
    
    always @(x or y) begin
        if(x==0 | x==639 | y==0 | y==479) bg_rgb <= 12'hFFF;
        else bg_rgb <= mem2[mem[y*640+x]];
    end
endmodule