/****************************************************************************
 * axi4_wb_bridge.sv
 ****************************************************************************/

/**
 * Module: axi4_wb_bridge
 * 
 * TODO: Add module documentation
 */
module axi4_wb_bridge #(
		AXI4_ADDRESS_WIDTH=32,
		AXI4_DATA_WIDTH=32,
		AXI4_ID_WIDTH=4,
		WB_ADDRESS_WIDTH=32,
		WB_DATA_WIDTH=32
		) (
		input				axi_clk,
		input				rstn,
		axi4_if.slave		axi_i,
		wb_if.master		wb_o
		);

	// Simple bridging logic 

	reg									last_access_write = 0;
	reg[2:0]							access_state = 0;
	reg[WB_ADDRESS_WIDTH-1:0]			WB_ADR_r = 0;
	reg									WB_WE_r = 0;
	reg[WB_DATA_WIDTH/8-1:0]			WB_SEL_r = 0;
	reg[WB_DATA_WIDTH-1:0]				WB_DATA_W_r = 0;
	reg									AXI_DATA_LAST_r = 0;
	reg[3:0]							AXI_LEN_r = 0;
	reg[AXI4_DATA_WIDTH-1:0]			AXI_DAT_R_r = 0;
	reg[AXI4_ID_WIDTH-1:0]				AXI_ID_r = 0;
	
	assign axi_i.BRESP = 2'b00;
	assign axi_i.RRESP = 2'b00;
	
	assign wb_o.CTI = 3'b000;
	assign wb_o.BTE = 2'b00;
	
	always @(posedge axi_clk) begin
		if (rstn == 0) begin
			access_state <= 0;
			WB_ADR_r <= 0;
			WB_WE_r <= 0;
			WB_SEL_r <= 0;
			WB_DATA_W_r <= 0;
			AXI_DATA_LAST_r <= 0;
			AXI_LEN_r <= 0;
			AXI_DAT_R_r <= 0;
			AXI_ID_r <= 0;
		end else begin
			case (access_state) 
				0: begin
					if (axi_i.ARVALID && axi_i.ARREADY) begin
						WB_ADR_r <= axi_i.ARADDR;
						WB_WE_r <= 0;
						WB_SEL_r <= {(WB_DATA_WIDTH/8){1'b1}};
						AXI_LEN_r <= axi_i.ARLEN;
						AXI_ID_r <= axi_i.ARID;
						access_state <= 1;
					end else if (axi_i.AWVALID && axi_i.AWREADY) begin
						WB_ADR_r <= axi_i.AWADDR;
						WB_WE_r <= 1;
						AXI_ID_r <= axi_i.AWID;
						access_state <= 3;
					end
				end
			
				// Wait for WB slave to respond to read
				1: begin
					if (wb_o.ACK) begin
						WB_ADR_r <= 0;
						WB_WE_r <= 0;
						AXI_DAT_R_r <= wb_o.DAT_R;
						access_state <= 2;
					end
				end
				
				// Wait until AXI responds to read
				2: begin
					if (axi_i.RREADY) begin
						access_state <= 0;
					end
				end
				
				//***********************************************************
			
				// Wait for data to arrive
				3: begin
					if (axi_i.WVALID) begin
						WB_DATA_W_r <= axi_i.WDATA;
						AXI_DATA_LAST_r <= axi_i.WLAST;
						access_state <= 4;
					end
				end
				
				4: begin
					if (wb_o.ACK) begin
						if (AXI_DATA_LAST_r) begin
							access_state <= 5;
						end else begin
							access_state <= 3;
						end
					end
				end
				
				5: begin
					if (axi_i.BREADY) begin
						// Done
						access_state <= 0;
					end
				end

			endcase
		end
	end
	
	assign wb_o.ADR = WB_ADR_r;
	assign wb_o.WE = WB_WE_r;
	assign wb_o.SEL = WB_SEL_r;
	assign wb_o.CYC = (access_state == 1 || access_state == 4);
	assign wb_o.STB = (access_state == 1 || access_state == 4);
	assign axi_i.RDATA = AXI_DAT_R_r;
	assign axi_i.RVALID = (access_state == 2);
	assign axi_i.RLAST = (access_state == 2);
	assign axi_i.RID = (access_state == 2)?AXI_ID_r:0;

	assign axi_i.ARREADY = (access_state == 0);
	assign axi_i.AWREADY = (access_state == 0);
	
	assign axi_i.WREADY = (access_state == 3);
	assign wb_o.DAT_W = WB_DATA_W_r;
	
	assign axi_i.BVALID = (access_state == 5);
	assign axi_i.BID = (access_state == 5)?AXI_ID_r:0;

endmodule

