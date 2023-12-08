`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Reference book: "FPGA Prototyping by Verilog Examples"
//                      "Xilinx Spartan-3 Version"
// Written by: Dr. Pong P. Chu
// Published by: Wiley, 2008
//
// Adapted for Basys 3 by David J. Marion aka FPGA Dude
//
//////////////////////////////////////////////////////////////////////////////////


module scoreText(
    input clk,
    input [6:0] score1, score2,
    input [9:0] x, y,
    output text_on,
    output reg [11:0] text_rgb
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] char_addr;
    reg [3:0] row_addr;
    reg [2:0] bit_addr;
    wire [7:0] ascii_word;
    wire score_on;
    
   // instantiate ascii rom
   ROM_Dig2Text rom_dig2text(.clk(clk), .addr(rom_addr), .data(ascii_word));
   
   // ---------------------------------------------------------------------------
   // score region
   // - display two-digit score and ball # on top left
   // - scale to 16 by 32 text size
   // - line 1, 16 chars: "Score: dd"
   // ---------------------------------------------------------------------------
    wire [3:0] num3; // From left to right
    wire [3:0] num2;
    wire [3:0] num1;
    wire [3:0] num0;
    
    // BCD
    ROM_BinaryToBCD bcdP1(num3,num2,score1,clk);
    ROM_BinaryToBCD bcdP2(num1,num0,score2,clk);
   
   assign score_on_1 = (y >= 32) && (y < 64) && (x < 9'd143);
   assign score_on_2 = (y >= 32) && (y < 64) && (x > 9'd2500);

   always @* begin 
        if( score_on_1 || score_on_2 )
            case(x[7:4])
                4'h0 : char_addr = 7'h53;     // S
                4'h1 : char_addr = 7'h43;     // C
                4'h2 : char_addr = 7'h4F;     // O
                4'h3 : char_addr = 7'h52;     // R
                4'h4 : char_addr = 7'h45;     // E
                4'h5 : char_addr = 7'h3A;     // :
                4'h6 : char_addr = (score_on_1) ? {3'b011, num3} : {3'b011, num1};    // tens digit
                4'h7 : char_addr = (score_on_1) ? {3'b011, num2} : {3'b011, num0};    // ones digit
                4'h8 : char_addr = 7'h00;     //
                4'h9 : char_addr = 7'h00;     //
                default : char_addr = 7'h20;
            endcase
        else
            char_addr = 7'h20;
    end
    
    // mux for ascii ROM addresses and rgb
    always @* begin
        row_addr = y[4:1];
        bit_addr = x[3:1];
        
        if(ascii_bit)
            text_rgb = 12'hfff;
        else
            text_rgb = (x < 320) ? 12'hF00 : 12'h0C0; // background 
    end
    
    assign text_on = (y >= 32) && (y < 64);
    
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
      
endmodule