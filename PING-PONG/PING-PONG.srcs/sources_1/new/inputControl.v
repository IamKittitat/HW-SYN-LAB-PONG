`timescale 1ns / 1ps

module inputControl(
input wire clk,
input wire clk50,
input wire PS2Clk,
input wire PS2Data,
output wire [1:0] de_keyboard1,
output wire [1:0] de_keyboard2,
output wire sp_enter,
output wire tx
);
    // UART --------------------------------------------------  
    wire tready;
    wire ready;
    wire tstart;
    reg start=0;
    wire[31:0] tbuf;
    wire[ 7:0] tbus;
      
    uart_buf_con tx_con (
        .clk    (clk),
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
    
    // PS2 receiver --------------------------------------------------
    reg  [15:0] keycodev=0;
    wire [15:0] keycode;
    reg  [ 2:0] bcount=0;
    wire flag;
    reg cn=0;
    
    PS2Receiver PS2Receiver (
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

    // Turn keycode to signal ----------------------------------------------------------
    wire up, down, W, S, enter;
    gen_keyboard gk(clk, flag, keycode, W, S, up, down, enter);
 
    wire [1:0] keyboard1 = {up, down};
    wire [1:0] keyboard2 = {W, S};

   // debouncer and single pulser ---------------------------------------------------------
    wire [1:0] de_keyboard1;
    wire [1:0] de_keyboard2;
    wire sp_enter;
    wire de_enter;
    debounce d0(clk, keyboard1[1], de_keyboard1[1]);
    debounce d1(clk,keyboard1[0], de_keyboard1[0]);
    debounce d2(clk, keyboard2[1], de_keyboard2[1]);
    debounce d3(clk,keyboard2[0], de_keyboard2[0]);
    debounce d4(clk, enter, de_enter);
    singlepulser sp4(clk, de_enter, sp_enter);
endmodule
