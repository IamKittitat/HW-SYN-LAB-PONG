module pixel_gen(
   input [9:0] h_cnt,
   input clk,
   input valid,
   input [9:0]v_cnt,
   input [9:0]ballX,
   input [9:0]ballY,
   input [9:0]posX1,
   input [9:0]posX2,
   input [8:0]posY1,
   input [8:0]posY2,
   input [6:0]score1,
   input [6:0]score2,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue,
   output BouncingObject
   );
   
    reg ball_inX;
    reg ball_inY;
    
    // position of border and paddle
    wire border =  (v_cnt[8:3]==0) || (v_cnt[8:3]==59);
    wire paddle1 = ((h_cnt>=posX1+8) && (h_cnt<=posX1+18) &&(v_cnt>=posY1+8)&& (v_cnt<=posY1+48));
    wire paddle2 = ((h_cnt>=posX2+8) && (h_cnt<=posX2+18) &&(v_cnt>=posY2+8) && (v_cnt<=posY2+48)) ;
    
    wire text_on;
    wire [11:0] text_rgb;

    scoreText score_text( clk, score1, score2, h_cnt, v_cnt, text_on, text_rgb);
    
    assign  BouncingObject = border | paddle1 | paddle2 ; // active if the border or paddle is redrawing itself
    always @(posedge clk)
        if(ball_inX==0) ball_inX <= (h_cnt==ballX) & ball_inY; 
        else ball_inX <= !(h_cnt == ballX+8);
    
    always @(posedge clk)
        if(ball_inY==0) ball_inY <= (v_cnt==ballY); 
        else ball_inY <= !(v_cnt==ballY+8);

    wire ball = ball_inX & ball_inY;
    
     reg [11:0] bg_rgb = 12'h000;
    //ROM_Bg ROM_Bg(h_cnt, v_cnt, bg_rgb);
    
    always @(*) begin
        if(valid && BouncingObject)
            if(paddle1) {vgaRed, vgaGreen, vgaBlue} = ( h_cnt[0] == v_cnt[0] ) ? 12'hfcc: 12'hf0b;
            else if (paddle2) {vgaRed, vgaGreen, vgaBlue} = ( h_cnt[0] == v_cnt[0] ) ? 12'hccf: 12'h01C;
            else {vgaRed, vgaGreen, vgaBlue} = 	12'hfff;
        else if(valid && ball)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(valid && text_on)
            {vgaRed, vgaGreen, vgaBlue}= text_rgb;
        else if(valid)
            {vgaRed, vgaGreen, vgaBlue} = bg_rgb;
        else
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
    end
    
endmodule