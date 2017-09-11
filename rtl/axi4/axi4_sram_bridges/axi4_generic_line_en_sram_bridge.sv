/****************************************************************************
 * axi4_generic_line_en_sram_bridge.sv
 ****************************************************************************/

/**
 * Module: axi4_generic_line_en_sram_bridge
 * 
 * TODO: Add module documentation
 */
module axi4_generic_line_en_sram_bridge #(
			parameter int MEM_ADDR_BITS=10,
			parameter AXI_ADDRESS_WIDTH=32,
			parameter AXI_DATA_WIDTH=1024,
			parameter AXI_ID_WIDTH=4,
			parameter bit[MEM_ADDR_BITS-1:0] MEM_ADDR_OFFSET=0
		) (
			input									clk,
			input									rst_n,
			axi4_if.slave							axi_if,
			generic_sram_line_en_if.sram_client		sram_if
		);
	
	generic_sram_byte_en_if #(
		.NUM_ADDR_BITS  (MEM_ADDR_BITS),
		.NUM_DATA_BITS  ($bits(sram_if.read_data))
		) u_sram_byte_if (
		);
	
//	assign sram_if.addr = u_sram_byte_if.sram.addr;
//	assign u_sram_byte_if.sram.read_data = sram_if.read_data;
//	assign sram_if.read_en = u_sram_byte_if.sram.read_en;
//	assign sram_if.write_en = u_sram_byte_if.sram.write_en;
//	assign sram_if.write_data = u_sram_byte_if.sram.write_data;

	assign sram_if.addr = u_sram_byte_if.addr;
	assign u_sram_byte_if.read_data = sram_if.read_data;
	assign sram_if.read_en = u_sram_byte_if.read_en;
	assign sram_if.write_en = u_sram_byte_if.write_en;
	assign sram_if.write_data = u_sram_byte_if.write_data;
	
	axi4_generic_byte_en_sram_bridge #(
		.MEM_ADDR_BITS      (MEM_ADDR_BITS     ), 
		.AXI_ADDRESS_WIDTH  (AXI_ADDRESS_WIDTH ), 
		.AXI_DATA_WIDTH     (AXI_DATA_WIDTH    ), 
		.AXI_ID_WIDTH       (AXI_ID_WIDTH      ),
		.MEM_ADDR_OFFSET    (MEM_ADDR_OFFSET   )
		) axi4_generic_byte_en_sram_bridge (
		.clk                (clk               ), 
		.rst_n              (rst_n             ), 
		.axi_if             (axi_if            	), 
		.sram_if            (u_sram_byte_if.sram_client));
	
endmodule

