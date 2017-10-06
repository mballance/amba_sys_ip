
class axi4_sram_test_base extends Axi4SramTestBase #(axi4_sram_env);
	
	`uvm_component_utils(axi4_sram_test_base)
	
	function new(string name, uvm_component parent=null);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this, "Main");
		
	endtask
	
endclass

