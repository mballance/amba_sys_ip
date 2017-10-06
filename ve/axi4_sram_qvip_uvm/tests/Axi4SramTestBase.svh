/****************************************************************************
 * Axi4SramTestBase.svh
 ****************************************************************************/

/**
 * Class: Axi4SramTestBase
 * 
 * TODO: Add class documentation
 */
class Axi4SramTestBase #(parameter type env_t=int) extends uvm_test;
	typedef Axi4SramTestBase #(env_t) this_t;
	
	`uvm_component_param_utils(this_t)

	env_t		m_env;

	function new(string name, uvm_component parent=null);
		super.new(name, parent);

	endfunction
	
	function void build_phase(uvm_phase phase);
		m_env = env_t::type_id::create("m_env", this);
	endfunction


endclass


