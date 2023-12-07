`timescale 1ns / 1ps

module gen_keyboard(
    input clk,
    input flag,
    input [15:0]keycode ,
    output reg w,
    output reg s,
    output reg up,
    output reg down,
    output reg enter
    );

    always @(posedge clk) begin
        if(flag) begin
            if(keycode == 16'hf01d) begin
                w <= 0;
            end else if(keycode == 16'hf01b) begin
                s <= 0;
            end else if(keycode == 16'hf075) begin
                up <= 0;
            end else if(keycode == 16'hf072) begin
                down <= 0;
            end else if(keycode == 16'hf05A) begin
                enter <= 0;
            end else if(keycode[7:0] == 8'h1d) begin
                w <= 1;
            end else if(keycode[7:0] == 8'h1b) begin
                s <= 1;
            end else if(keycode[7:0] == 8'h75) begin
                up <= 1;
            end else if(keycode[7:0] == 8'h72) begin
                down <= 1;
            end else if(keycode[7:0] == 8'h5A) begin
                enter <= 1;
            end
        end
    end
endmodule