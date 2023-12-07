`timescale 1ns / 1ps

module ROM_BinaryToBCD(
output [3:0] number1,
output [3:0] number0,
input [6:0] addr,
input clk 
); (* synthesis, rom_block = "ROM_CELL XYZ01" *)

    reg [7:0] rom[31:0];
    initial
    begin
        $readmemb("rom.data", rom);
    end
    
    assign  {number1,number0} = rom[addr];
endmodule