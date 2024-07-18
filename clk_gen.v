module clk_gen (input clk, output wire i_clk, output wire d_clk, output wire u_clk);
    
    clk_n #(.freq(100)) c100 (.clk(clk), .clk_out(i_clk));
    clk_n #(.freq(25000000)) c25M (.clk(clk), .clk_out(d_clk));
    clk_n #(.freq(5)) c5 (.clk(clk), .clk_out(u_clk));

endmodule