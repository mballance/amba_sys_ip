
class axi4_sram_env extends Axi4SramEnvBase;
	`uvm_component_utils(axi4_sram_env)

	function new(string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	/**
	 * Function: build_phase
	 *
	 * Override from class uvm_component
	 */
	virtual function void build_phase(input uvm_phase phase);
		super.build_phase(phase);
	endfunction

	/**
	 * Function: connect_phase
	 *
	 * Override from class uvm_component
	 */
	virtual function void connect_phase(input uvm_phase phase);
		super.connect_phase(phase);
	endfunction
	
	
endclass
