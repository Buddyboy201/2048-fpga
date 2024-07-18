module clk_n 
    #(parameter freq = 'd100000000)
(
    input clk,
    output reg clk_out = 0
);
    reg [31:0] max_count = 'd100000000 / (freq*'d2);
    reg [31:0] count = 0;

    always @(posedge clk) begin
        if ((count >= (max_count - 1))) 
            count <= 'd0;
        else
            count <= count + 1;
    end

    always @(posedge clk) begin
        clk_out = (count == max_count - 1) ? ~clk_out : clk_out;
    end

endmodule