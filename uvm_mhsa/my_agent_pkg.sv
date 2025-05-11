//=====================================================================
// Description:
// my agent package
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.6 Initial version, Huang Chaofan
// V1 date: 4.24 add my_monitor_o, Huang Chaofan
// ====================================================================

package my_agent_pkg;
  
  import uvm_pkg::*;
  import my_sequence_pkg::*;

  class my_agent_config extends uvm_object;
    virtual dut_if dut_vif;
  endclass : my_agent_config

  typedef uvm_sequencer #(my_transaction) my_sequencer;

  class my_driver extends uvm_driver #(my_transaction);

    `uvm_component_utils(my_driver)

    string report_id = get_type_name();

    my_agent_config agent_config;
    virtual dut_if.master dut_vif;
    int flag;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(my_agent_config)::get(this, "", "agent_config", agent_config))
        `uvm_fatal("NO_AGENT_CFG_IN_DRV", "Class agent_config was not set!")
        dut_vif = agent_config.dut_vif;
    endfunction : build_phase

    task run_phase(uvm_phase phase);

      flag = 0;

      forever begin
        seq_item_port.get_next_item(req);

        @(posedge dut_vif.mst_cb);

        if(dut_vif.done == 1)
          flag = 1;

        if(req.start == 0 && dut_vif.done == 0 && flag == 0)
        begin
          dut_vif.mst_cb.soc_write_en <= 1;
          dut_vif.mst_cb.start        <= req.start;
          dut_vif.mst_cb.soc_data_in  <= req.soc_data_in;
          dut_vif.mst_cb.soc_addr     <= req.soc_addr;
          @(posedge dut_vif.mst_cb);
          dut_vif.mst_cb.soc_write_en <= 0;
        end
        else
        begin
          dut_vif.mst_cb.soc_write_en <= 0;
          dut_vif.mst_cb.start        <= req.start;
          dut_vif.mst_cb.soc_data_in  <= req.soc_data_in;
          dut_vif.mst_cb.soc_addr     <= req.soc_addr;
        end

        seq_item_port.item_done();
      end

      
    endtask : run_phase

  endclass: my_driver

  class my_monitor_i extends uvm_monitor;
    `uvm_component_utils(my_monitor_i)

    string report_id = get_type_name();

    uvm_analysis_port #(my_transaction) ap;

    my_agent_config agent_config;
    virtual dut_if.others  dut_vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      ap = new("ap", this);
      if(!uvm_config_db #(my_agent_config)::get(this, "", "agent_config", agent_config))
        `uvm_fatal("NO_AGENT_CFG_IN_MON_I", "Class agent_config was not set!")
      dut_vif = agent_config.dut_vif;
    endfunction : build_phase

    task run_phase(uvm_phase phase);
      my_transaction tx_monitor_i;
      forever begin
        
        @(posedge dut_vif.mon_cb);
        // condition here
        if(dut_vif.soc_write_en) begin
          tx_monitor_i = my_transaction::type_id::create("tx_monitor_i");
          // monitor data here
          tx_monitor_i.start       = dut_vif.start;
          tx_monitor_i.done        = dut_vif.done;
          tx_monitor_i.input_base  = dut_vif.input_base;
          tx_monitor_i.output_base = dut_vif.output_base;
          tx_monitor_i.soc_write_en= dut_vif.soc_write_en;
          tx_monitor_i.soc_data_in = dut_vif.soc_data_in;
          tx_monitor_i.soc_addr    = dut_vif.soc_addr;
          tx_monitor_i.soc_data_out= dut_vif.soc_data_out;
          //`uvm_info()
          // $display("monitor_i sample soc_data_in: %h", dut_vif.soc_data_in);
          ap.write(tx_monitor_i); 
        end
      end
    endtask : run_phase

  endclass : my_monitor_i

  class my_monitor_o extends uvm_monitor;
    `uvm_component_utils(my_monitor_o)

    string report_id = get_type_name();

    uvm_analysis_port #(my_transaction) ap;

    my_agent_config agent_config;
    virtual dut_if.others  dut_vif;
    int flag;
    int num;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      ap = new("ap", this);
      if(!uvm_config_db #(my_agent_config)::get(this, "", "agent_config", agent_config))
        `uvm_fatal("NO_AGENT_CFG_IN_MON_O", "Class agent_config was not set!")
      dut_vif = agent_config.dut_vif;
    endfunction : build_phase
      
    task run_phase(uvm_phase phase);
      my_transaction tx_monitor_o;
      flag = 0;
      num = 0;
      forever begin
        @(posedge dut_vif.mon_cb);
        // condition here
        if(dut_vif.done)
        begin
          flag = 1;
          @(posedge dut_vif.mon_cb);
        end

        if((dut_vif.done || flag) && dut_vif.soc_addr >= 32'h0000_0c00 && dut_vif.soc_addr < 32'h0000_0e00 && num < 512) 
        begin
          tx_monitor_o = my_transaction::type_id::create("tx_monitor_o");
          // monitor data here
          tx_monitor_o.start        = dut_vif.start;
          tx_monitor_o.done         = dut_vif.done;
          tx_monitor_o.input_base   = dut_vif.input_base;
          tx_monitor_o.output_base  = dut_vif.output_base;
          tx_monitor_o.soc_write_en = dut_vif.soc_write_en;
          tx_monitor_o.soc_data_in  = dut_vif.soc_data_in;
          tx_monitor_o.soc_addr     = dut_vif.soc_addr;
          tx_monitor_o.soc_data_out = dut_vif.soc_data_out;
          //`uvm_info()
          // $display("monitor_o sample soc_data_out: %h", dut_vif.soc_data_out);
          num = num + 1;
          ap.write(tx_monitor_o); 
        end
        else if(num == 512)
        begin
          flag = 0;
          num = 0;
        end
      end
    endtask : run_phase

  endclass : my_monitor_o

  class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)
     
    uvm_analysis_port #(my_transaction) ap;

    my_sequencer my_sequencer_h;
    my_driver    my_driver_h;
    my_monitor_i   my_monitor_i_h;
    my_monitor_o   my_monitor_o_h;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
      if(is_active == UVM_ACTIVE) begin
        my_sequencer_h = my_sequencer::type_id::create("my_sequencer_h", this);
        my_driver_h    = my_driver   ::type_id::create("my_driver_h", this);
        my_monitor_i_h = my_monitor_i::type_id::create("my_monitor_i_h", this);
      end
      else if (is_active == UVM_PASSIVE) begin
        my_monitor_o_h = my_monitor_o::type_id::create("my_monitor_o_h", this);
      end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      if(is_active == UVM_ACTIVE) begin
        my_driver_h.seq_item_port.connect(my_sequencer_h.seq_item_export);
        ap = my_monitor_i_h.ap;
      end
      else if (is_active == UVM_PASSIVE) begin
        ap = my_monitor_o_h.ap;
      end
    endfunction : connect_phase

  endclass : my_agent

endpackage : my_agent_pkg