module game_state_update (input clk, input rst, input r, input l, input u, input d, output reg [26:0] grid, output wire lose);

    wire [26:0] new_grid;
    wire [3:0] space_to_update;
    reg [15:0] count0 = 'b1110111101110001;
    wire rand_num0 = count0 % 'd9;
    reg [15:0] count1 = 'b1111111011111111;
    wire rand_num1 = count1 % 'd9;
    
    wire [3:0] blank_tiles_count;
    game_state gs (.grid(grid), .rand_count(count0), .r(r), .l(l), .u(u), .d(d), .new_grid(new_grid), .blank_tiles_count(blank_tiles_count));
    lose_check lc (.grid(grid), .lose(lose));
    
    initial begin
        count0 = 'b1110111101110001;
        count1 = 'b1111111011111111;
        grid = 0;
    end

    always @(posedge clk) begin
        count0 <= {count0[14:0], count0[15]^~count0[14]^~count0[12]^~count0[3]};
        count1 <= {count1[14:0], count1[15]^~count1[14]^~count1[12]^~count1[3]};
    end

    integer i, rand_blank;
    always @(posedge clk) begin
      if (rst) begin
        grid = 0;
        if (count0%9 == count1%9) begin
          grid[(count0%9)*3 +: 3] = 'd1;
          grid[((count1+1)%9)*3 +: 3] = 'd2;
        end
        else begin
          grid[(count0%9)*3 +: 3] = 'd1;
          grid[(count1%9)*3 +: 3] = 'd2;
        end
      end   
      else begin
        if (r | l | u | d) begin 
          grid = new_grid;
          if (blank_tiles_count != 0) begin
            rand_blank = count0 % (blank_tiles_count);
            i = 0;
            while (i < 9) begin
              if (grid[i*3 +: 3] == 'd0) begin
                if (rand_blank == 'd0) begin
                  grid[i*3 +: 3] = (count1%2 == 0) ? 'd1 : 'd2;
                end
                rand_blank = rand_blank - 1;
              end
              i = i + 1;
            end
            
          end
          
        end
      end
    end

endmodule