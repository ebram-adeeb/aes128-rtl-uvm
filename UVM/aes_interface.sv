interface intf_aes(input logic clk);
    logic  [127:0] plain_text; 
    logic  [127:0] cipher_key;
    logic  valid_in;
    logic  reset;
    logic  [127:0] cipher_text;
    logic  valid_out;
    
    clocking cb_drv @(posedge clk);
        default input #1step output #0; 
        output  plain_text; 
        output  cipher_key;
        output  valid_in;
        input   valid_out;
        output  reset;
    endclocking

    clocking cb_mon @(posedge clk);
        default input #1step; 
        input  plain_text; 
        input  cipher_key;
        input  valid_in;
        input  reset;
        input  cipher_text;
        input  valid_out;
    endclocking

endinterface