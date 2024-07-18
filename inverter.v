module inverter (input inv, input [8:0] r_in, output wire [8:0] r_out);

    //assign r_out[6 +: 3] = r_in[0 +: 3];
    //assign r_out[3 +: 3] = r_in[3 +: 3];
    //assign r_out[0 +: 3] = r_in[6 +: 3];

    assign r_out = (inv) ? {r_in[0 +: 3], r_in[3 +: 3], r_in[6 +: 3]} : r_in;
    
    /*always @(*) begin
        r_out[6 +: 3] = r_in[0 +: 3];
        r_out[3 +: 3] = r_in[3 +: 3];
        r_out[0 +: 3] = r_in[6 +: 3];
    end*/

endmodule

module inverter_3 (input inv, input [8:0] in0, input [8:0] in1, input [8:0] in2, output wire [8:0] out0, output wire [8:0] out1, output wire [8:0] out2);

    inverter op0 (.inv(inv), .r_in(in0), .r_out(out0));
    inverter op1 (.inv(inv), .r_in(in1), .r_out(out1));
    inverter op2 (.inv(inv), .r_in(in2), .r_out(out2));
    
endmodule