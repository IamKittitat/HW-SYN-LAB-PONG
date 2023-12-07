module singlepulser(clk, ip, ip_singlepulser);
    input clk;
    input ip;
    output ip_singlepulser;

    reg ip_debounced_delay;
    reg ip_singlepulser;

    always @(posedge clk) begin
        ip_singlepulser <= ip & (!ip_debounced_delay);
        ip_debounced_delay <= ip;
    end

endmodule
