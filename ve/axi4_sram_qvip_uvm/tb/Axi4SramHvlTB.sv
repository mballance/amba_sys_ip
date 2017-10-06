/****************************************************************************
 * Axi4SramHvlTB.sv
 ****************************************************************************/
`include "uvm_macros.svh"

module Axi4SramTBClkGen(output clock, output reset);
	reg clock_r = 0;
	reg reset_r = 1;
	parameter reset_cnt = 100;
	
	assign clock = clock_r;
	assign reset = reset_r;
	
	initial begin
		repeat (reset_cnt*2) begin
			#10ns;
			clock_r <= ~clock_r;
		end
		
		reset_r <= 0;
		
		forever begin
			#10ns;
			clock_r <= ~clock_r;
		end
	end
endmodule

/**
 * Module: Axi4SramHvlTB
 * 
 * TODO: Add module documentation
 */
module Axi4SramHvlTB;
	import uvm_pkg::*;

//	typedef Axi4SramTB.sram.core.axi4_if_t axi4_if_t;
	typedef virtual mgc_axi4 #(32,32,32,4,1,16) axi4_if_t;
	initial begin
//		virtual Axi4SramTB.sram.core.axi4_if_t vif;
		automatic axi4_if_t vif = Axi4SramTB.axi4_qvip.qvip.axi4_if;
		
		run_test();
	end

	// Connect the clock generator to the HDL TB
	bind Axi4SramTB Axi4SramTBClkGen Axi4SramTBClkGen_inst(.clock(clock), .reset(reset));

endmodule


