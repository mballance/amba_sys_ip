/****************************************************************************
 * Axi4SramEnv.svh
 ****************************************************************************/

/**
 * Class: Axi4SramEnvBase
 * 
 * TODO: Add class documentation
 */
class Axi4SramEnvBase extends uvm_env;
	`uvm_component_utils(Axi4SramEnvBase)
	
	function new(string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
	endfunction

endclass


