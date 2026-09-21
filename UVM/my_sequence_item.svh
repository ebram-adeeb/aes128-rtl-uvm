class my_sequence_item extends uvm_sequence_item;
    rand logic reset;
    rand logic  valid_in;

    rand logic  [127:0] plain_text; 
    rand logic  [127:0] cipher_key;


    logic  [127:0] cipher_text;
    logic  valid_out;
    `uvm_object_utils_begin(my_sequence_item)
        `uvm_field_int(reset,       UVM_ALL_ON)
        `uvm_field_int(plain_text,  UVM_ALL_ON)
        `uvm_field_int(cipher_key,  UVM_ALL_ON)
        `uvm_field_int(valid_in,    UVM_ALL_ON)
        `uvm_field_int(cipher_text, UVM_ALL_ON)
        `uvm_field_int(valid_out,   UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "my_sequence_item");
        super.new(name);
    endfunction
endclass 