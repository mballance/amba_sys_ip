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
			parameter AXI_ID_WIDTH=4,
			parameter INIT_FILE=""
		) (
			input				clk,
			input				rst,
			// ** 
			// * Write Address channel
			// ** 
			input[(AXI_ADDRESS_WIDTH-1):0]	AWADDR,
			input[(AXI_ID_WIDTH-1):0]		AWID,
			input[7:0]						AWLEN,
			input[2:0]						AWSIZE,
			input[1:0]						AWBURST,
			input							AWLOCK,
			input[3:0]						AWCACHE,
	
			input[2:0]						AWPROT,
			input[3:0]						AWQOS,
			input[3:0]						AWREGION,
	
			// AWUSER excluded (Not recommended)
			input							AWVALID,
			output							AWREADY,

			// ** 
			// * Write Data channel
			// ** 
			// WID excluded (AXI4)
			input[(AXI_DATA_WIDTH-1):0]		WDATA,
			input[(AXI_DATA_WIDTH/8)-1:0]		WSTRB,
			input								WLAST,
			// WUSER excluded (Not recommended)
			input								WVALID,
			output								WREADY,
	
			// **
			// * Write response channel
			// **
			input[(AXI_ID_WIDTH-1):0]			BID,
			input[1:0]							BRESP,
			// BUSER excluded (Not recommended)
			input								BVALID,
			output								BREADY,
	
			// ** 
			// * Read Address channel
			// ** 
			input[(AXI_ID_WIDTH-1):0]			ARID,
			input[(AXI_ADDRESS_WIDTH-1):0]		ARADDR,
			input[7:0]							ARLEN,
			input[2:0]							ARSIZE,
			input[1:0]							ARBURST,
			input								ARLOCK,
			input[3:0]							ARCACHE,
	
			input[2:0]							ARPROT,
			input[3:0]							ARQOS,
			input[3:0]							ARREGION,
	
			// ARUSER excluded (Not recommended)
			input								ARVALID,
			output								ARREADY,
	
			// ** 
			// * Read Data channel
			// ** 
			output[(AXI_ID_WIDTH-1):0]			RID,
			output[(AXI_DATA_WIDTH-1):0]		RDATA,
			output[1:0]							RRESP,
			output								RLAST,
			// RUSER excluded (Not recommended)
			output								RVALID,
			input								RREADY
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
	
	axi4_if #(
		.AXI4_ADDRESS_WIDTH  (AXI_ADDRESS_WIDTH ), 
		.AXI4_DATA_WIDTH     (AXI_DATA_WIDTH    ), 
		.AXI4_ID_WIDTH       (AXI_ID_WIDTH      )
		) s ();

	assign s.AWADDR = AWADDR;
	assign s.AWID = AWID;
	assign s.AWLEN = AWLEN;
	assign s.AWSIZE = AWSIZE;
	assign s.AWBURST = AWBURST;
	assign s.AWLOCK = AWLOCK;
	assign s.AWCACHE = AWCACHE;
	assign s.AWPROT = AWPROT;
	assign s.AWQOS = AWQOS;
	assign s.AWREGION = AWREGION;
	assign s.AWVALID = AWVALID;
	assign AWREADY = s.AWREADY;
	
		// ** 
		// * Write Data channel
		// ** 
		// WID excluded (AXI4)
	assign s.WDATA = WDATA;
	assign s.WSTRB = WSTRB;
	assign s.WLAST = WLAST;
	assign s.WVALID = WVALID;
	assign WREADY = s.WREADY;
	
		// **
		// * Write response channel
		// **
	assign BID = s.BID;
	assign BRESP = s.BRESP;
	assign BVALID = s.BVALID;
	assign s.BREADY = BREADY;
	
		// ** 
		// * Read Address channel
		// ** 
	assign s.ARADDR = ARADDR;
	assign s.ARID = ARID;
	assign s.ARLEN = ARLEN;
	assign s.ARSIZE = ARSIZE;
	assign s.ARBURST = ARBURST;
	assign s.ARLOCK = ARLOCK;
	assign s.ARCACHE = ARCACHE;
	assign s.ARPROT = ARPROT;
	assign s.ARQOS = ARQOS;
	assign s.ARREGION = ARREGION;
	assign s.ARVALID = ARVALID;
	assign ARREADY = s.ARREADY;
	
		// ** 
		// * Read Data channel
		// ** 
	assign RID = s.RID;
	assign RDATA = s.RDATA;
	assign RRESP = s.RRESP;
	assign RLAST = s.RLAST;
	assign RVALID = s.RVALID;
	assign s.RREADY = RREADY;
		
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
		.clk                (clk               		), 
		.rst_n              (!rst            		), 
		.axi_if             (s            				), 
		.sram_if            (u_bridge2sram.sram_client	));
	
    generic_sram_byte_en_w #(
    	.MEM_DATA_BITS   (AXI_DATA_WIDTH), 
    	.MEM_ADDR_BITS   (MEM_ADDR_BITS ),
		.INIT_FILE		(INIT_FILE)
    	) ram_w (
    	.i_clk           (clk          ), 
    	.s				 (u_bridge2sram.sram)
    	);
    
endmodule

