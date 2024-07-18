module lose_check (input [26:0] grid, output reg lose);
    
    reg [2:0] i, j;
    
    always @(*) begin
        lose = 1'b1;

        // check for any zeroes
        for (i = 0; i < 3; i = i + 1)
            for (j = 0; j < 3; j = j + 1)
                if (grid[(9*i + 3*j)+:3] == 'd0)
                    lose = 1'b0;

        // check if two blocks next to each other are the same
        for (i = 0; i < 3; i = i + 1)
            for (j = 0; j < 2; j = j + 1)
                if (grid[(9*i + 3*j)+:3] == grid[(9*i + 3*(j+1))+:3])
                    lose = 1'b0;

        // check if two blocks on top of each other are the same
        for (j = 0; j < 3; j = j + 1)
            for (i = 0; i < 2; i = i + 1)
                if (grid[(9*i + 3*j)+:3] == grid[(9*(i+1) + 3*j)+:3])
                    lose = 1'b0;
        
    end
    
endmodule


/*module game_state (input [26:0] grid, input r, input l, input u, input d, output wire [26:0] new_grid);
  wire [8:0] t0, t1, t2, tt0, tt1, tt2, s0, s1, s2, ss0, ss1, ss2, r0, r1, r2;
  extract ex (.grid(grid), .rc((r | l) & ~(u | d)), .t0(t0), .t1(t1), .t2(t2));
  inverter_4 inv1 (.in0(t0), .in1(t1), .in2(t2), .out0(tt0), .out1(tt1), .out2(tt2));
  row_ops_4 ops (.in0(tt0), .in1(tt1), .in2(tt2), .out0(s0), .out1(s1), .out2(s2));
  inverter_4 inv2 (.in0(s0), .in1(s1), .in2(s2), .out0(ss0), .out1(ss1), .out2(ss2));
  cols_to_rows transposer (.c0(ss0), .c1(ss1), .c2(ss2), .r0(r0), .r1(r1), .r2(r2));
  assign new_grid = (r | l | u | d) ? {r2, r1, r0} : grid;
  
endmodule*/
module game_state (input [26:0] grid, input [15:0] rand_count, input r, input l, input u, input d, output reg [26:0] new_grid, output reg [3:0] blank_tiles_count);
    wire [8:0] t0, t1, t2, i0, i1, i2, s0, s1, s2, ii0, ii1, ii2, r0, r1, r2;
    wire rc, inv;
    assign rc = (r | l) & ~(u | d);
    assign inv = l | u;

    extract ex (.rc(rc), .grid(grid), .t0(t0), .t1(t1), .t2(t2));
    inverter_3 inverter1 (.inv(inv), .in0(t0), .in1(t1), .in2(t2), .out0(i0), .out1(i1), .out2(i2));
    row_ops_3 ops (.in0(i0), .in1(i1), .in2(i2), .out0(s0), .out1(s1), .out2(s2));
    inverter_3 inverter2 (.inv(inv), .in0(s0), .in1(s1), .in2(s2), .out0(ii0), .out1(ii1), .out2(ii2));
    cols_to_rows transposer (.rc(rc), .c0(ii0), .c1(ii1), .c2(ii2), .r0(r0), .r1(r1), .r2(r2));

    // count blank tiles
    // loop through {r2, r1, r0}'s blank tiles' blank_tiles_count times

    reg [26:0] tmp_new_grid;
    reg [3:0] i, j;
    always @(*) begin
        blank_tiles_count = 0;
        tmp_new_grid = {r2, r1, r0};
        for (i = 0; i < 9; i = i + 1)
            if (tmp_new_grid[i*3 +: 3] == 'd0)
                blank_tiles_count = blank_tiles_count + 1;
        
        new_grid = (r | l | u | d) ? tmp_new_grid : grid;
    end

endmodule
