/*module row_ops(input [23:0] row_in, output reg [23:0] row);
    integer current, leading;

    always @(*) begin
        row = row_in;
        current = 0;
        leading = 1;

        while (leading < 3 && current < 3) begin
            if (row[leading*3 +: 3] == 0) begin
                leading = leading + 1;
            end
            else if (row[leading*3 +: 3] == row[current*3 +: 3]) begin
                row[current*3 +: 3] = row[current*3 +: 3] + row[leading*3 +: 3];
                row[leading*3 +: 3] = 0;
                leading = leading + 1;
                current = current + 1;
            end
            else if (row[current*3 +: 3] != row[leading*3 +: 3]) begin
                if (row[current*3 +: 3] == 0) begin
                    row[current*3 +: 3] = row[leading*3 +: 3];
                    row[leading*3 +: 3] = 0;
                    leading = leading + 1;
                    current = current + 1;
                end
                else begin
                    if (leading - current == 1) begin
                        leading = leading + 1;
                        current = current + 1;
                    end
                    else begin
                        row[(current + 1)*3 +: 3] = row[leading*3 +: 3];
                        row[leading*3 +: 3] = 0;
                        leading = leading + 1;
                        current = current + 1;
                    end
                end
            end
        end
    end
endmodule*/

module row_ops (input [8:0] r_in, output reg [8:0] r);
    reg [2:0] l, c;
    always @(*) begin
        r = r_in;
        c = 0;
        l = 1;
        while (l < 3 && c < 3) begin
            if (r[c*3 +: 3] == 'd0) begin
                if (r[l*3 +: 3] != 'd0) begin
                    r[c*3 +: 3] = r[l*3 +: 3];
                    r[l*3 +: 3] = 'b0;
                end
            end
            else if (r[c*3 +: 3] == r[l*3 +: 3]) begin
                r[c*3 +: 3] = r[c*3 +: 3] + 1'b1;
                r[l*3 +: 3] = 'b0;
                c = c + 1;
            end
            else begin
                if (r[l*3 +: 3] != 'd0) begin
                    if (l - c > 1) begin
                        r[(c+1)*3 +: 3] = r[l*3 +: 3];
                        r[l*3 +: 3] = 'b0;
                    end
                    c = c + 1;
                end
            end
            l = l + 1;
        end
    end
endmodule

module row_ops_3 (input [8:0] in0, input [8:0] in1, input [8:0] in2, output wire [8:0] out0, output wire [8:0] out1, output wire [8:0] out2);

    row_ops op0 (.r_in(in0), .r(out0));
    row_ops op1 (.r_in(in1), .r(out1));
    row_ops op2 (.r_in(in2), .r(out2));
    
endmodule

/*module row_ops(input [8:0] row_in, output reg [8:0] row);
    integer current, leading;

    always @(*) begin
        row = row_in;
        current = 0;
        leading = 1;

        while (leading < 3 && current < 3) begin
            if (row[leading*3 +: 3] != 0) begin
                if (row[leading*3 +: 3] == row[current*3 +: 3]) begin
                    row[current*3 +: 3] = row[current*3 +: 3] + 1'b1;
                    row[leading*3 +: 3] = 0;
                end
                else if (row[current*3 +: 3] != row[leading*3 +: 3]) begin
                    if (row[current*3 +: 3] == 0) begin
                        row[current*3 +: 3] = row[leading*3 +: 3];
                        row[leading*3 +: 3] = 0;
                    end
                    else begin
                        if (leading - current > 1) begin
                            row[(current + 1)*3 +: 3] = row[leading*3 +: 3];
                            row[leading*3 +: 3] = 0;
                        end
                    end
                end
                current = current + 1;
            end
            
            leading = leading + 1;
        end
    end
endmodule*/