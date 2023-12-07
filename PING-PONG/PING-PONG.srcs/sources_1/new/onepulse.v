module onepulse(clk, ip, ip_onepulse);
    input clk;
    input ip;
    output ip_onepulse;

    reg ip_debounced_delay;
    reg ip_onepulse;

    always @(posedge clk) begin
        ip_onepulse <= ip & (!ip_debounced_delay);
        ip_debounced_delay <= ip;
    end

endmodule
