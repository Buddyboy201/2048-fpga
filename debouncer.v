module debouncer (input clk, input btnRST, input btnR, input btnL, input btnU, input btnD, output wire rst, output wire r, output wire l, output wire u, output wire d);

    btn_debouncer right (.clk(clk), .btn(btnR), .out(r));
    btn_debouncer left (.clk(clk), .btn(btnL), .out(l));
    btn_debouncer up (.clk(clk), .btn(btnU), .out(u));
    btn_debouncer down (.clk(clk), .btn(btnD), .out(d));
    btn_debouncer rst_debounce (.clk(clk), .btn(btnRST), .out(rst));

endmodule


module btn_debouncer (input clk, input btn, output reg out = 0);
    reg [1:0] sync_buf = 'b00;

    always @(posedge clk)
        sync_buf <= {btn, sync_buf[1]};

    always @(posedge clk)
        out <= sync_buf[0] & sync_buf[1];
        
endmodule

