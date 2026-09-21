class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)
    virtual interface intf_aes my_vif;
    my_driver    driver;
    my_monitor   monitor;
    my_sequencer seqr;
    uvm_analysis_port #(my_sequence_item) my_agent_analysis_port;
    function new (string name = "my_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_agent...");
        super.build_phase(phase);
        my_agent_analysis_port = new("my_agent_analysis_port", this);
        driver  = my_driver::type_id::create("driver", this);
        monitor = my_monitor::type_id::create("monitor", this);
        seqr    = my_sequencer::type_id::create("seqr", this);
        if (!uvm_config_db#(virtual intf_aes)::get(this, "", "my_vif", my_vif)) begin
            `uvm_fatal(get_full_name(), "Could not find virtual interface in config_db")
        end
        uvm_config_db#(virtual interface intf_aes)::set(this, "driver", "my_vif" , my_vif);
        uvm_config_db#(virtual interface intf_aes)::set(this, "monitor", "my_vif" , my_vif);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_agent...");
        super.connect_phase(phase);
        monitor.my_analysis_port.connect(this.my_agent_analysis_port);

        driver.seq_item_port.connect(seqr.seq_item_export);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask
endclass