class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    virtual interface intf_aes my_vif;
    my_sequence_item seq_item;
    uvm_analysis_port #(my_sequence_item) my_analysis_port;

    function new(string name = "my_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_monitor...");
        super.build_phase(phase);
        my_analysis_port = new("my_analysis_port", this);
        if (!uvm_config_db#(virtual intf_aes)::get(this, "", "my_vif", my_vif)) begin
            `uvm_fatal(get_full_name(), "Could not find virtual interface in config_db")
        end
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_monitor...");
        super.connect_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        @(my_vif.cb_mon);
        forever begin
            seq_item = my_sequence_item::type_id::create("seq_item");            
            //Capture Inputs
            @(my_vif.cb_mon);
            seq_item.reset      <= my_vif.cb_mon.reset;            
            seq_item.valid_in   <= my_vif.cb_mon.valid_in;            
            seq_item.plain_text <= my_vif.cb_mon.plain_text;            
            seq_item.cipher_key <= my_vif.cb_mon.cipher_key;

            //Capture Outputs
            if (my_vif.cb_mon.reset === 1'b1 && my_vif.cb_mon.valid_in === 1'b1) begin
                while (my_vif.cb_mon.valid_out !== 1'b1) begin
                    @(my_vif.cb_mon);
                    if (my_vif.cb_mon.reset === 1'b0) break;
                end
            end

            seq_item.cipher_text <= my_vif.cb_mon.cipher_text;
            seq_item.valid_out   <= my_vif.cb_mon.valid_out;
            @(my_vif.cb_mon);
            //report monitored values
            `uvm_info(get_name(), $sformatf("MONITORED TRANSACTION | reset: %0b | valid_in: %0b | plain_text: 0x%0h | key: 0x%0h | valid_out: %0b | cipher_text: 0x%0h", 
                      seq_item.reset, seq_item.valid_in, seq_item.plain_text, seq_item.cipher_key, seq_item.valid_out, seq_item.cipher_text), UVM_HIGH)
            my_analysis_port.write(seq_item);
        end
    endtask
endclass