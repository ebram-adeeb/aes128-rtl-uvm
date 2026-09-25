`timescale 1ns/1ps
module top;
    import uvm_pkg::*;
    import pack1::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;             

    intf_aes in1 (clk);

    aes_wrapper DUT (
        .clk         (clk),
        .reset       (in1.reset),
        .valid_in    (in1.valid_in),
        .plain_text  (in1.plain_text),
        .cipher_key  (in1.cipher_key),
        .cipher_text (in1.cipher_text),
        .valid_out   (in1.valid_out)
    );

    initial begin      
        in1.reset      = 1'b0;     
        in1.plain_text = 128'b0;
        in1.cipher_key = 128'b0;

        uvm_config_db#(virtual intf_aes)::set(null, "uvm_test_top", "my_vif", in1);
        run_test("my_test");
    end
endmodule