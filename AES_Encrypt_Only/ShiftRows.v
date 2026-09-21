module ShiftRows 
#(parameter STATE_WIDTH = 128)
(
    input  wire [STATE_WIDTH-1:0] state_in,
    output wire [STATE_WIDTH-1:0] state_out
);
    assign state_out = {
        //column0
        //    B0                 B5                 B10                B15
        state_in[127:120], state_in[87:80]  , state_in[47:40]  , state_in[7:0]   ,
        //column1
        //    B4                 B9                 B14                B3       
        state_in[95:88]  , state_in[55:48]  , state_in[15:8]   , state_in[103:96],
        //column2
        //    B8                 B13                 B2                B7   
        state_in[63:56]  , state_in[23:16]  , state_in[111:104], state_in[71:64] ,
        //column3
        //    B12                B1                 B6                B11      
        state_in[31:24]  , state_in[119:112], state_in[79:72]  , state_in[39:32]  };
endmodule
