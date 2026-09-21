module col_mix_single (
    input  [31:0] in,
    output [31:0] out
);
    wire [7:0] s3,s2,s1,s0;

    assign s3 = in[07:00]; 
    assign s2 = in[15:08]; 
    assign s1 = in[23:16]; 
    assign s0 = in[31:24]; 

    assign out [31:24] = xtime(s0) ^ (xtime(s1) ^ s1) ^ s2 ^ s3; // 2*s0 + 3*s1 + s2 + s3
    assign out [23:16] = s0 ^ xtime(s1) ^ (xtime(s2) ^ s2) ^ s3; // s0 + 2*s1 + 3*s2 + s3
    assign out [15:08] = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3) ^ s3); // s0 + s1 + 2*s2 + 3*s3
    assign out [07:00] = (xtime(s0) ^ s0) ^ s1 ^ s2 ^ xtime(s3); // 3*s0 + s1 + s2 + 2*s3

    function [7:0] xtime (input [7:0] in_byte); begin
        xtime = {in_byte[6:0], 1'b0} ^ (in_byte[7] ? 8'h1B : 8'h00);    
    end
    endfunction
endmodule
