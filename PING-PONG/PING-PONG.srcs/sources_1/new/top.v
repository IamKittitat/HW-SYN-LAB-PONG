`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc 
// Engineer: Arthur Brown
// 
// Create Date: 07/27/2016 02:04:01 PM
// Design Name: Basys3 Keyboard Demo
// Module Name: top
// Project Name: Keyboard
// Target Devices: Basys3
// Tool Versions: 2016.X
// Description: 
//     Receives input from USB-HID in the form of a PS/2, displays keyboard key presses and releases over USB-UART.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//     Known issue, when multiple buttons are pressed and one is released, the scan code of the one still held down is ometimes re-sent.
//////////////////////////////////////////////////////////////////////////////////


module top(
    input         clk,
    input         PS2Data,
    input         PS2Clk,
    output        tx,
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
    
    // Recieve INPUT -------------------------------------------------------------------
     // UART --------------------------------------------------  
    wire       tready;
    wire       ready;
    wire       tstart;
    reg        start=0;
    wire[31:0] tbuf;
    wire[ 7:0] tbus;
      
    uart_buf_con tx_con (
        .clk    (clk   ),
        .bcount (bcount),
        .tbuf   (tbuf  ),  
        .start  (start ), 
        .ready  (ready ), 
        .tstart (tstart),
        .tready (tready),
        .tbus   (tbus  )
    );
    
    uart_tx get_tx (
        .clk    (clk),
        .start  (tstart),
        .tbus   (tbus),
        .tx     (tx),
        .ready  (tready)
    );
    
    // PS2 reciever --------------------------------------------------
    reg  [15:0] keycodev=0;
    wire [15:0] keycode;
    reg  [ 2:0] bcount=0;
    wire        flag;
    reg         cn=0;
    
    PS2Receiver uut (
        .clk(clk50),
        .kclk(PS2Clk),
        .kdata(PS2Data),
        .keycode(keycode),
        .oflag(flag)
    );
    
    always@(keycode)
        if (keycode[7:0] == 8'hf0) begin
            cn <= 1'b0;
            bcount <= 3'd0;
        end else if (keycode[15:8] == 8'hf0) begin
            cn <= keycode != keycodev;
            bcount <= 3'd5;
        end else begin
            cn <= keycode[7:0] != keycodev[7:0] || keycodev[15:8] == 8'hf0;
            bcount <= 3'd2;
        end
    
    always@(posedge clk)
        if (flag == 1'b1 && cn == 1'b1) begin
            start <= 1'b1;
            keycodev <= keycode;
        end else
            start <= 1'b0;
    
    // binary to ASCII -------------------------------------------------------
    bin2ascii #(
        .NBYTES(2)
    ) conv (
        .I(keycodev),
        .O(tbuf)
    );
    // END OF recieve INPUT ---------------------------------------------------------------------

    // Turn keycode to signal ----------------------------------------------------------
    wire up, down, W, S, enter;
    gen_keyboard gk(clk, flag, keycode, W, S, up, down, enter);
    
    wire [1:0] keyboard1 = {up, down};
    wire [1:0] keyboard2 = {W, S};
   
    wire [1:0] de_keyboard1;
    wire [1:0] de_keyboard2;
       
   // debouncer and one pulser ---------------------------------------------------------
    wire one_enter;
    wire de_enter;
    debounce d0(clk, keyboard1[1], de_keyboard1[1]);
    debounce d1(clk,keyboard1[0], de_keyboard1[0]);
    debounce d2(clk, keyboard2[1], de_keyboard2[1]);
    debounce d3(clk,keyboard2[0], de_keyboard2[0]);
    debounce d4(clk, enter, de_enter);
    onepulse o4(clk, de_enter, one_enter);

    // End of Turn keycode to signal ----------------------------------------------------------
   
   
    // ball position
    reg ball_inX, ball_inY;
    wire [9:0]ballX;
    wire [9:0]ballY;
    
    // player 1 position 
    wire [9:0]posX1;
    wire [8:0]posY1;
    
    // player 2 position 
    wire [9:0]posX2;
    wire [8:0]posY2;
    
    wire BouncingObject;
    
    // score
    wire [2:0]score1;
    wire [2:0]score2;
    wire [1:0]state;

    wire serve;
    wire [1:0]ballStatus;
    
    reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
  
    // generate graphic and VGA
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
    
    Player player1(clk, rst, state, de_keyboard2, ballY, 1'b0, posX1, posY1);
    Player player2(clk, rst, state, de_keyboard1, ballY, 1'b1, posX2, posY2);
    
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
    Game game(clk, rst, ballStatus, one_enter, state, score1, score2,serve);

    // Display score on Seven segment
    wire [3:0] num3; // From left to right
    wire [3:0] num2;
    wire [3:0] num1;
    wire [3:0] num0;
    
    assign num0=score2;
    assign num1=1'b0;
    assign num2=score1;
    assign num3=1'b0;

    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,clk13);
    
endmodule