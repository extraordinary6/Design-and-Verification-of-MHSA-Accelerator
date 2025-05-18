//=====================================================================
// Description:
// my sequence package
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.2 Initial version, Huang Chaofan
// ====================================================================

package my_sequence_pkg;

  import uvm_pkg::*;

  class my_transaction extends uvm_sequence_item;

    rand bit               start;
    rand bit               done;
    rand logic [31:0]      input_base;
    rand logic [31:0]      output_base;
    rand bit               soc_write_en;
    rand logic [63:0]      soc_data_in;
    rand logic [31:0]      soc_addr;
    rand logic [63:0]      soc_data_out;

    `uvm_object_utils_begin(my_transaction)
      `uvm_field_int(start, UVM_ALL_ON)
      `uvm_field_int(done, UVM_ALL_ON)
      `uvm_field_int(input_base, UVM_ALL_ON)
      `uvm_field_int(output_base, UVM_ALL_ON)
      `uvm_field_int(soc_write_en, UVM_ALL_ON)
      `uvm_field_int(soc_data_in, UVM_ALL_ON)
      `uvm_field_int(soc_addr, UVM_ALL_ON)
      `uvm_field_int(soc_data_out, UVM_ALL_ON)
    `uvm_object_utils_end

    // constraint here
    constraint c_addr {
      soc_addr inside {[0:32'h0000_3FFF]};
    }

    function new(string name = "");
      super.new(name);
    endfunction : new

  endclass : my_transaction

  // sequence defined below
  class mem_rand_write_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(mem_rand_write_seq)

    function new(string name = "mem_rand_write_seq");
      super.new(name);
    endfunction : new

    task body;
      my_transaction tx;
      tx = my_transaction::type_id::create("tx");
      for (int i = 0; i < 512; i = i + 1)  // X
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0800 + i;
          tx.soc_data_in = {$urandom(), $urandom()};
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // Q
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_1000 + i;
          tx.soc_data_in = {$urandom(), $urandom()};
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // K
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_2000 + i;
          tx.soc_data_in = {$urandom(), $urandom()};
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // V
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_3000 + i;
          tx.soc_data_in = {$urandom(), $urandom()};
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // O
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0000 + i;
          tx.soc_data_in = {$urandom(), $urandom()};
        finish_item(tx);
      end

    endtask : body
  endclass: mem_rand_write_seq

  class mem_inc_write_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(mem_inc_write_seq)

    function new(string name = "mem_inc_write_seq");
      super.new(name);
    endfunction : new

    task body;
      my_transaction tx;
      tx = my_transaction::type_id::create("tx");
      for (int i = 0; i < 512; i = i + 1)  // X
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0800 + i;
          tx.soc_data_in = 64'h0000_0000_0000_0000 + i;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // Q
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_1000 + i;
          tx.soc_data_in = 64'h0000_0000_0000_0000 + i;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // K
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_2000 + i;
          tx.soc_data_in = 64'h0000_0000_0000_0000 + i;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // V
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_3000 + i;
          tx.soc_data_in = 64'h0000_0000_0000_0000 + i;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // O
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0000 + i;
          tx.soc_data_in = 64'h0000_0000_0000_0000 + i;
        finish_item(tx);
      end

    endtask : body
  endclass: mem_inc_write_seq

  class mem_allone_write_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(mem_allone_write_seq)

    function new(string name = "mem_allone_write_seq");
      super.new(name);
    endfunction : new

    task body;
      my_transaction tx;
      tx = my_transaction::type_id::create("tx");
      for (int i = 0; i < 512; i = i + 1)  // X
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0800 + i;
          tx.soc_data_in = 64'hffff_ffff_ffff_ffff;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // Q
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_1000 + i;
          tx.soc_data_in = 64'hffff_ffff_ffff_ffff;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // K
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_2000 + i;
          tx.soc_data_in = 64'hffff_ffff_ffff_ffff;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // V
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_3000 + i;
          tx.soc_data_in = 64'hffff_ffff_ffff_ffff;
        finish_item(tx);
      end

      for (int i = 0; i < 2048; i = i + 1) // O
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0000 + i;
          tx.soc_data_in = 64'hffff_ffff_ffff_ffff;
        finish_item(tx);
      end
    endtask : body
  endclass: mem_allone_write_seq

  class compute_start_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(compute_start_seq)

    function new(string name = "compute_start_seq");
      super.new(name);
    endfunction : new
  
    task body;
      my_transaction tx;
      tx = my_transaction::type_id::create("tx");

      start_item(tx);
        tx.start       = 1;
        tx.soc_data_in = 0;
        tx.soc_addr    = 0;
      finish_item(tx);
    endtask : body
  endclass: compute_start_seq

  class mem_read_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(mem_read_seq)

    function new(string name = "mem_read_seq");
      super.new(name);
    endfunction : new

    task body;
      my_transaction tx;
      tx = my_transaction::type_id::create("tx");
      
      for (int i = 0; i < 512; i = i + 1)  // output
      begin
        start_item(tx);
          tx.start       = 0;
          tx.soc_addr    = 32'h0000_0c00 + i;
          tx.soc_data_in = 0;
        finish_item(tx);
      end

    endtask : body
  
  endclass: mem_read_seq
    

endpackage : my_sequence_pkg