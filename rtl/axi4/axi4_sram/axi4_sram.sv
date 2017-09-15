/****************************************************************************
 * axi4_sram.sv
 ****************************************************************************/

/**
 * Module: axi4_sram
 * 
 * TODO: Add module documentation
 */
module axi4_sram #(
			parameter MEM_ADDR_BITS=10,
			parameter AXI_ADDRESS_WIDTH=32,
			parameter AXI_DATA_WIDTH=1024,
			parameter AXI_ID_WIDTH=4
		) (
			input				ACLK,
			input				ARESETn,
			axi4_if.slave		s
		);

	// synopsys translate_off
	initial begin
		$display("SRAM path %m");
		if ($bits(s.ARID) != AXI_ID_WIDTH) begin
			$display("SRAM %m: expect %0d ID bits ; receive %0d", AXI_ID_WIDTH, $bits(s.ARID));
			$finish();
		end
	end
	// synopsys translate_on
	
	generic_sram_byte_en_if #(
		.NUM_ADDR_BITS  (MEM_ADDR_BITS ), 
		.NUM_DATA_BITS  (AXI_DATA_WIDTH)
		) u_bridge2sram ();

	axi4_generic_byte_en_sram_bridge #(
		.MEM_ADDR_BITS		(MEM_ADDR_BITS),
		.AXI_ADDRESS_WIDTH  (AXI_ADDRESS_WIDTH ), 
		.AXI_DATA_WIDTH     (AXI_DATA_WIDTH    ), 
		.AXI_ID_WIDTH       (AXI_ID_WIDTH      )
		) u_axi4_sram_bridge (
		.clk                (ACLK               		), 
		.rst_n              (ARESETn            		), 
		.axi_if             (s            				), 
		.sram_if            (u_bridge2sram.sram_client	));
	
    generic_sram_byte_en_w #(
    	.MEM_DATA_BITS   (AXI_DATA_WIDTH), 
    	.MEM_ADDR_BITS   (MEM_ADDR_BITS )
    	) ram_w (
    	.i_clk           (ACLK          ), 
    	.s				 (u_bridge2sram.sram)
    	);
    
endmodule

