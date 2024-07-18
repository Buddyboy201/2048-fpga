module five12(input clk, input btnRST, input btnR, input btnL, input btnU, input btnD, output wire hsync, output wire vsync, output wire [2:0] red, output wire [2:0] green, output wire [1:0] blue);
  
  wire [26:0] grid;
  wire lose;
  wire rst, r, l, u, d;
  wire i_clk, d_clk, u_clk;
  clk_gen clock_gen (.clk(clk), .i_clk(i_clk), .d_clk(d_clk), .u_clk(u_clk));

  debouncer debounce (.clk(i_clk), .btnRST(btnRST), .btnR(btnR), .btnL(btnL), .btnU(btnU), .btnD(btnD), .rst(rst), .r(r), .l(l), .u(u), .d(d));
  
  game_state_update state_manager (.clk(u_clk), .rst(rst), .r(r), .l(l), .u(u), .d(d), .grid(grid), .lose(lose));
 
  vga640x480 vga_c (.grid_test(grid), .dclk(d_clk), .clr(1'b0), .lose(lose), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue));
endmodule