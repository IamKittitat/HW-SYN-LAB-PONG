`timescale 1ns / 1ps

module top(
    input clk,
    input PS2Data,
    input PS2Clk,
    input rst,
    output hsync,
    output vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output [6:0] seg,
    output dp,
    output [3:0] an
);
    
    // Clock --------------------------------------------------
    reg clk50=0;
    always @(posedge clk) begin
        clk50 = ~clk50;
    end
    
    wire clk1;
    wire clk13;
    clock_divisor clock_divisor1(clk1, clk,clk13);
    
    // Input Control  --------------------------------------------------
    wire [1:0] de_keyboard1;
    wire [1:0] de_keyboard2;
    wire sp_enter;
    inputControl(clk, clk50, PS2Clk, PS2Data, de_keyboard1,de_keyboard2,sp_enter);

    // Ball position  --------------------------------------------------
    reg ball_inX, ball_inY;
    wire [9:0]ballX;
    wire [9:0]ballY;
    
    // Player position --------------------------------------------------
    wire [9:0]posX1;
    wire [8:0]posY1;
    wire [9:0]posX2;
    wire [8:0]posY2;
    
    wire BouncingObject;
    
    // Score --------------------------------------------------
    wire [6:0]score1;
    wire [6:0]score2;
    wire [1:0]state;

    wire serve;
    wire [1:0]ballStatus;
    
    reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
  
    // Generate graphic and VGA --------------------------------------------------
    wire valid;
    wire [9:0]h_cnt;
    wire [9:0]v_cnt;
    
    vga_controller vga1( clk1, rst, hsync, vsync, valid, h_cnt, v_cnt );
      
    pixel_gen pix1(
           h_cnt, clk1, valid, v_cnt,
           ballX, ballY, posX1, posX2, posY1, posY2,
           score1, score2,
           vgaRed, vgaGreen, vgaBlue,
           BouncingObject
       );
    
    Player player1(clk, rst, state, de_keyboard2, 1'b0, posX1, posY1);
    Player player2(clk, rst, state, de_keyboard1, 1'b1, posX2, posY2);
    
    always @(*) begin
        if(BouncingObject & (h_cnt==ballX) & (v_cnt==ballY+ 4)) CollisionX1=1'b1;
        else CollisionX1=1'b0;
    end
    
    always @(*) begin
        if(BouncingObject & (h_cnt==ballX+8) & (v_cnt==ballY+ 4)) CollisionX2=1'b1;
        else CollisionX2=1'b0;
    end

    always @(*) begin
        if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY)) CollisionY1=1'b1;
        else CollisionY1=1'b0;
    end

    always @(*) begin
        if((BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY+8))) CollisionY2=1'b1;
        else CollisionY2=1'b0;
    end
    
    Ball ball(clk, rst, state, serve, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ballX, ballY, ballStatus);
    GameLogic GameLogic(clk, rst, ballStatus, sp_enter, state, score1, score2,serve);

    // Display score on Seven segment --------------------------------------------------
    // num3, num2, num1, num0
    wire [3:0] num3;
    wire [3:0] num2;
    wire [3:0] num1;
    wire [3:0] num0;

    ROM_BinaryToBCD bcdP1(num3,num2,score1,clk13);
    ROM_BinaryToBCD bcdP2(num1,num0,score2,clk13);

    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,clk13);
endmodule