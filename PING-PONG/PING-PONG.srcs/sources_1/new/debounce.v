module debounce(clk, ip, ip_debounced);
    input clk;
    input ip;
    output ip_debounced;

    reg [3:0] debounced;

    always @(posedge clk) begin
        debounced <= {debounced[2:0], ip};
    end

    assign ip_debounced = &debounced;

endmodule


