/****************************************************************************
 * axi4_sram.sv
 ****************************************************************************/

/**
 * Module: axi4_rom
 * 
 * TODO: Add module documentation
 */
module axi4_rom #(
			parameter MEM_ADDR_BITS=10,
			parameter AXI_ADDRESS_WIDTH=32,
			parameter AXI_DATA_WIDTH=1024,
			parameter AXI_ID_WIDTH=4,
			parameter INIT_FILE=""
		) (
			input				ACLK,
			input				ARESETn,
			axi4_if.slave		s
		);
	
	// synopsys translate_off
	initial begin
		$display("ROM path %m");
	end

	initial begin
		if ($bits(s.ARID) != AXI_ID_WIDTH) begin
			$display("Error: %m - id width %0d ; expecting %0d",
					$bits(s.ARID), AXI_ID_WIDTH);
			$finish(1);
		end
	end
	// synopsys translate_on

    assign s.RRESP = {2{1'b0}};
    assign s.BRESP = {2{1'b0}};
    
    reg[2:0] 						write_state;
    reg[AXI_ID_WIDTH-1:0]			write_id;
	// synopsys translate_off
    reg[MEM_ADDR_BITS-1:0]			write_addr;
    reg[3:0]						write_count;
	// synopsys translate_on
    
    reg[2:0] 						read_state;
    reg[MEM_ADDR_BITS-1:4]		read_addr;
    wire[MEM_ADDR_BITS-1:0]			read_addr_w;
    reg[3:0]						read_count;
    reg[3:0]						read_offset;
    reg[3:0]						read_length;
    reg[AXI_ID_WIDTH-1:0]			read_id;
    reg[1:0]						read_burst;
    reg[3:0]						read_wrap_mask;

    always @(posedge ACLK)
    begin
    	if (!ARESETn) begin
    		write_state <= 2'b00;
    		write_id <= {AXI_ID_WIDTH{1'b1}};
	// synopsys translate_off
    		write_addr <= {MEM_ADDR_BITS{1'b0}};
    		write_count <= 4'b0000;
	// synopsys translate_on
    		read_state <= 2'b00;
    		read_addr <= {MEM_ADDR_BITS{1'b0}};
    		read_count <= 4'b0000;
    		read_length <= 4'b0000;
    	end else begin
	// synopsys translate_off
    		case (write_state) 
    			2'b00: begin // Wait Address state
    				if (s.AWVALID == 1'b1 && s.AWREADY == 1'b1) begin
    					write_addr <= s.AWADDR[MEM_ADDR_BITS+2:2];
    					write_id <= s.AWID;
    					write_count <= 0;
    					write_state <= 1;
    				end
    			end
    			
    			2'b01: begin // Wait for write data
    				if (s.WVALID == 1'b1 && s.WREADY == 1'b1) begin
//    					$display("%m: Error: write 'h%08h='h%08h", (write_addr+write_count), s.WDATA);
 //   					ram[write_addr + write_count] <= s.WDATA;
    					if (s.WLAST == 1'b1) begin
    						write_state <= 2;
    					end else begin
    						write_count <= write_count + 1;
    					end
    				end
    			end
    			
    			2'b10: begin  // Send write response
    				if (s.BVALID == 1'b1 && s.BREADY == 1'b1) begin
    					write_state <= 2'b00;
    				end
    			end
    			
    			default: begin
    				write_state <= 0;
    			end
    		endcase
	// synopsys translate_on
    		
    		case (read_state)
    			2'b00: begin // Wait address state
    				if (s.ARVALID && s.ARREADY) begin
//    					read_addr <= s.ARADDR[MEM_ADDR_BITS+2:2];
    					read_length <= s.ARLEN;
    					read_burst <= s.ARBURST;
    					read_count <= 0;
    					read_state <= 1;
    					read_id <= s.ARID;
    					
						read_addr <= s.ARADDR[MEM_ADDR_BITS+2:6];
		    			read_offset <= s.ARADDR[5:2];
		    		
    					case (s.ARBURST)
    						2: begin
    							case (s.ARLEN) 
    								0,1: read_wrap_mask <= 1;
    								2,3: read_wrap_mask <= 3;
    								4,5,6,7: read_wrap_mask <= 7;
    								default: read_wrap_mask <= 15;
    							endcase
    						end
    						default: read_wrap_mask <= 'hf;
    					endcase
    				end
    			end
    			
    			// Propagate address to data
    			1: begin
    				read_state <= 2;
    			end
    		
    			// Propagate address to data
    			2: begin
    				read_state <= 3;
    			end
    			
    			3: begin 
    				if (s.RVALID && s.RREADY) begin
    					if (read_count == read_length) begin
    						read_state <= 1'b0;
    					end else begin
    						read_count <= read_count + 1;
    						read_state <= 4;
    					end
    					
    					case (read_burst)
    						2: begin
    							read_offset <= (read_offset & ~read_wrap_mask) |
    								((read_offset + 1) & read_wrap_mask);
    						end
    						
    						default: begin
    							if (read_offset == 'hf) begin
    								read_addr <= read_addr + 1;
    							end
    							read_offset <= read_offset + 1;
    						end
    					endcase
    					
    				end
    			end
    			
    			4: begin
    				read_state <= 2;
    			end
    			
    			default: begin
    				read_state <= 0;
    			end
    		endcase
    	end
    end
    
//    assign read_addr_w = (read_state == 0)?s.ARADDR[MEM_ADDR_BITS+2:2]:(read_addr+read_offset);
    assign read_addr_w = {read_addr,read_offset};
    wire[AXI_DATA_WIDTH-1:0]			read_data;

    generic_rom #(
    	.DATA_WIDTH     (AXI_DATA_WIDTH    ), 
    	.ADDRESS_WIDTH  (MEM_ADDR_BITS ), 
    	.INIT_FILE      (INIT_FILE     )
    	) u_rom (
    	.i_clk          (ACLK        ), 
    	.i_address      (read_addr_w ), 
    	.o_read_data    (read_data));
    	
//    assign s.RDATA = 'h0;
    
    assign s.AWREADY = (write_state == 0);
    assign s.WREADY = (write_state == 1);
    
    assign s.BVALID = (write_state == 2);
    assign s.BID = (write_state == 2)?write_id:0;
    
    assign s.ARREADY = (read_state == 1'b0);
    assign s.RVALID = (read_state == 3);

    assign s.RDATA = read_data;
    assign s.RLAST = (read_state == 3 && read_count == read_length)?1'b1:1'b0;
    assign s.RID = (read_state == 3)?read_id:0;

endmodule

