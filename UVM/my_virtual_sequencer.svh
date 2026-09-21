class my_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(my_virtual_sequencer)
    my_sequencer seqr;

    function new(string name = "my_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass