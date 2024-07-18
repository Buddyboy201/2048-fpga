module extract (input rc, input [26:0] grid, output reg [8:0] t0, output reg [8:0] t1, output reg [8:0] t2);
    always @(*) begin
        if (rc) begin
            t0 = grid[8:0];
            t1 = grid[17:9];
            t2 = grid[26:18];
        end
        else begin
            t0 = {grid[0*9+0*3 +: 3], grid[1*9+0*3 +: 3], grid[2*9+0*3 +: 3]};
            t1 = {grid[0*9+1*3 +: 3], grid[1*9+1*3 +: 3], grid[2*9+1*3 +: 3]};
            t2 = {grid[0*9+2*3 +: 3], grid[1*9+2*3 +: 3], grid[2*9+2*3 +: 3]};
        end
    end
endmodule

module cols_to_rows (input rc, input [8:0] c0, input [8:0] c1, input [8:0] c2, output wire [8:0] r0, output wire [8:0] r1, output wire [8:0] r2);
    
    assign r0 = (~rc) ? {c2[3*2 +: 3], c1[3*2 +: 3], c0[3*2 +: 3]} : c0;
    assign r1 = (~rc) ? {c2[3*1 +: 3], c1[3*1 +: 3], c0[3*1 +: 3]} : c1;
    assign r2 = (~rc) ? {c2[3*0 +: 3], c1[3*0 +: 3], c0[3*0 +: 3]} : c2;
    
endmodule