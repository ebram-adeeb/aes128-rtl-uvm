class my_sequencer extends uvm_sequencer #(my_sequence_item);
    `uvm_component_utils(my_sequencer)

    function new(string name = "my_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_sequencer...");
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_sequencer...");
        super.connect_phase(phase);
    endfunction
endclass