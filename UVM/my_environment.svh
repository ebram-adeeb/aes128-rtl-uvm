class my_environment extends uvm_env;
    `uvm_component_utils(my_environment)
    virtual interface intf_aes my_vif;
    my_agent        agent;
    my_scoreboard   scrbrd;
    my_subscriber   subscb;
    my_virtual_sequencer v_seqr;
    function new(string name = "my_environment", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_environment...");
        super.build_phase(phase);

        agent   = my_agent::type_id::create("agent", this);
        scrbrd  = my_scoreboard::type_id::create("scrbrd", this);
        subscb  = my_subscriber::type_id::create("subscb", this);
        v_seqr  = my_virtual_sequencer::type_id::create("v_seqr", this);

        if (!uvm_config_db#(virtual intf_aes)::get(this, "", "my_vif", my_vif)) begin
            `uvm_fatal(get_full_name(), "Could not find virtual interface in config_db")
        end
        uvm_config_db#(virtual interface intf_aes)::set(this, "agent", "my_vif" , my_vif);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_environment...");
        super.connect_phase(phase);
        agent.my_agent_analysis_port.connect(scrbrd.my_analysis_imp);
        agent.my_agent_analysis_port.connect(subscb.my_analysis_imp);
        v_seqr.seqr = agent.seqr;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask
endclass