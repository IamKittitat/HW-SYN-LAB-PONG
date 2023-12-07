`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

`define PLAYING 2'b00
`define PLAYER1WIN 2'b01
`define PLAYER2WIN 2'b10

module Game(clk, rst, ballStatus, enter, state, score1, score2, serve);
input clk, rst;
input [1:0] ballStatus;
input enter;
output reg [1:0] state;
output reg [6:0] score1, score2;
output reg serve;

// score: 0-3

// -- the state of our game; can be any of the following:
// -- 1. 'start' (the beginning of the game, before first serve)
// -- 2. 'serve' (waiting on a key press to serve the ball)
// -- 3. 'play' (the ball is in play, bouncing between paddles)
// -- 4. 'done' (the game is over, with a victor, ready for restart)


// state
// serve: Ball spawn in original point and cannot move
// play: Update score
// done: Print Score and Player move to original point

reg [1:0] nextState;
reg [6:0] nextScore1, nextScore2;
reg nextServe;

// serve
// 0: player1 serve
// 1: player 2 serce

always @(posedge clk) begin
    if(rst==1'b1) begin
        state <= `START;
        score1 <= 7'd0;
        score2 <= 7'd0;
        serve <= 1'b0;
    end
    else begin
        state <= nextState;
        score1 <= nextScore1;
        score2 <= nextScore2;
        serve <= nextServe;
    end
end

always @(*) begin
    case(state) 
        `START: begin
            nextState = `SERVE;
            nextScore1 = 7'd0;
            nextScore2 = 7'd0;
            nextServe = 1'b0;
        end
        `SERVE: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = serve;
            if(enter==1'b1) begin
                nextState = `PLAY;
            end
            else begin
                nextState = `SERVE;
            end
        end
        `PLAY: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = serve;
            if(ballStatus==`PLAYING) begin
                nextState = `PLAY;
            end
            else if(ballStatus==`PLAYER1WIN) begin
                nextScore1 = score1 + 1'b1;
                nextServe = 1'b1;
                if(nextScore1<7'd100) begin
                    nextState = `SERVE;
                end
                else begin
                    nextState = `DONE;
                end
            end
            else begin
                nextScore2 = score2 + 1'b1;
                nextServe = 1'b0;
                if(nextScore2<7'd100) begin
                    nextState = `SERVE;
                end
                else begin
                    nextState = `DONE;
                end
            end
        end
        `DONE: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = 1'b0;
            if(enter==1'b1) begin
                nextState = `START;
            end
            else begin
                nextState = `DONE;
            end
        end
    endcase
end
endmodule