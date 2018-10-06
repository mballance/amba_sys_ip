package amba_sys_ip.axi4

import chisel3._
import chisel3.util._
import std_protocol_if._
import chisellib.MathUtil

class Axi4WishboneBridge(val p : Axi4WishboneBridge.Parameters) extends Module {
  
 
//  require(p.axi4_p.ADDR_WIDTH == p.wb_p.ADDR_WIDTH,
//      s"ADDR_WIDTH mismatch: AXI4=${p.axi4_p.ADDR_WIDTH} Wishbone=${p.wb_p.ADDR_WIDTH}")
  require(p.axi4_p.DATA_WIDTH == p.wb_p.DATA_WIDTH,
      s"DATA_WIDTH mismatch: AXI4=${p.axi4_p.DATA_WIDTH} Wishbone=${p.wb_p.DATA_WIDTH}")
  
  val io = IO(new Bundle {
    val t = Flipped(new AXI4(p.axi4_p))
    val i = new Wishbone(p.wb_p)
  })
 
  val sWaitReq :: sWaitWbAck :: sWaitAxiReadReady :: sWaitAxiWriteData :: sWaitAxiWriteData2 :: sSendWriteResponse :: Nil = Enum(6)
  val access_state = RegInit(sWaitReq)

  val DATA_WORD_SIZE = (p.axi4_p.DATA_WIDTH/8).asUInt()
  val ADDR_BURST_MASK = (((p.axi4_p.DATA_WIDTH/8)*16)-1).asUInt()
  
  // Number of bits to represent the data width (32bit -> 2 ; 64-bit -> 3)
  val ADDR_WIDTH_OFF = MathUtil.clog2(p.axi4_p.DATA_WIDTH)
  // Number of bits to represent a 16-beat burst
  val ADDR_BURST_WIDTH_SZ = MathUtil.clog2(p.axi4_p.DATA_WIDTH*16)

  val wb_we_r = RegInit(init = Bool(false))
  val wb_sel_r = RegInit(init = UInt(0, (p.wb_p.DATA_WIDTH/8).W))
  val axi_len_r = RegInit(init = UInt(0, 8.W))
  val axi_id_r = RegInit(init = UInt(0, p.axi4_p.ID_WIDTH.W))
  val axi_dat_r_r = RegInit(init = UInt(0, p.axi4_p.DATA_WIDTH.W))
  val wb_dat_w_r = RegInit(init = UInt(0, p.axi4_p.DATA_WIDTH.W))
  val axi_dat_last_r = RegInit(init = Bool(false))
  val axi_size_r = RegInit(init = UInt(0, 3.W))
  val addr_high = RegInit(init = UInt(0, (p.axi4_p.ADDR_WIDTH-ADDR_BURST_WIDTH_SZ).W))
  val addr_low  = RegInit(init = UInt(0, ADDR_BURST_WIDTH_SZ.W))
  
  val count = RegInit(init = UInt(0, 4.W))
  val length = RegInit(init = UInt(0, 4.W))
  val wrap_mask  = RegInit(init = UInt(0, ADDR_BURST_WIDTH_SZ.W))
 
  switch (access_state) {
  is (sWaitReq) {
    when (io.t.arreq.ARVALID && io.t.arready) {
      wb_we_r := Bool(false)
     
      when (p.little_endian === Bool(true)) {
        switch (io.t.arreq.ARSIZE) {
        is (0.asUInt()) {
          wb_sel_r := Fill(1, 1.asUInt()) << (io.t.arreq.ARADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 0));
        }
        is (1.asUInt()) {
          wb_sel_r := Fill(2, 1.asUInt()) << (io.t.arreq.ARADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 1) * 2.asUInt());
        }
        is (2.asUInt()) {
          wb_sel_r := Fill(4, 1.asUInt()) << (io.t.arreq.ARADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 2) * 4.asUInt());
        }
        is (3.asUInt()) {
          wb_sel_r := Fill(8, 1.asUInt());
        }
        }
      } .otherwise {
        wb_sel_r := ((1.asUInt() << (io.t.arreq.ARSIZE+1.asUInt())).asUInt() - 1.asUInt()) << 
          (((p.axi4_p.DATA_WIDTH/8).asUInt()-io.t.arreq.ARADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 0))-1.asUInt());
      }
      
      axi_len_r := io.t.arreq.ARLEN
      axi_size_r := io.t.arreq.ARSIZE
      axi_id_r := io.t.arreq.ARID
      count := 0.asUInt()
      length := io.t.arreq.ARLEN

      when (io.t.arreq.ARBURST === 2.asUInt()) {
        addr_high := io.t.arreq.ARADDR(p.axi4_p.ADDR_WIDTH-1,ADDR_BURST_WIDTH_SZ)
        addr_low  := Cat(io.t.arreq.ARADDR(ADDR_BURST_WIDTH_SZ-1,ADDR_WIDTH_OFF), 
            Fill(ADDR_WIDTH_OFF,0.asUInt()))
        when (io.t.arreq.ARLEN >= 0.asUInt() && io.t.arreq.ARLEN <= 1.asUInt()) {
          wrap_mask := 1.asUInt()
        } .elsewhen (io.t.arreq.ARLEN >= 2.asUInt() && io.t.arreq.ARLEN <= 3.asUInt()) {
          wrap_mask := 3.asUInt()
        } .elsewhen (io.t.arreq.ARLEN >= 4.asUInt() && io.t.arreq.ARLEN <= 7.asUInt()) {
          wrap_mask := 7.asUInt()
        } .otherwise {
          wrap_mask := 15.asUInt()
        }
      } .otherwise {
          wrap_mask := Fill(ADDR_BURST_WIDTH_SZ, 1.asUInt())
          addr_high := io.t.arreq.ARADDR(p.axi4_p.ADDR_WIDTH-1,ADDR_BURST_WIDTH_SZ)
          // Capture the entire low address
          addr_low  := io.t.arreq.ARADDR(ADDR_BURST_WIDTH_SZ-1,0)
      }

      access_state := sWaitWbAck
    } .otherwise {
      when (io.t.awreq.AWVALID && io.t.awready) {
        wb_we_r := Bool(true)
          when (p.little_endian === Bool(true)) {
          switch (io.t.awreq.AWSIZE) {
          is (0.asUInt()) {
            wb_sel_r := Fill(1, 1.asUInt()) << (io.t.awreq.AWADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 0));
          }
          is (1.asUInt()) {
            wb_sel_r := Fill(2, 1.asUInt()) << (io.t.awreq.AWADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 1) * 2.asUInt());
          }
          is (2.asUInt()) {
            wb_sel_r := Fill(4, 1.asUInt()) << (io.t.awreq.AWADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 2) * 4.asUInt());
          }
          is (3.asUInt()) {
            wb_sel_r := Fill(8, 1.asUInt());
          }
          }
        } .otherwise {
          wb_sel_r := ((1.asUInt() << (io.t.awreq.AWSIZE+1.asUInt())).asUInt() - 1.asUInt()) << 
            (((p.axi4_p.DATA_WIDTH/8).asUInt()-io.t.awreq.AWADDR(log2Ceil(p.axi4_p.DATA_WIDTH/8)-1, 0))-1.asUInt());
        }
        axi_id_r := io.t.awreq.AWID
        count := 0.asUInt()
        length := io.t.awreq.AWLEN
        access_state := sWaitAxiWriteData
        
        when (io.t.awreq.AWBURST === 2.asUInt()) {
          addr_high := io.t.awreq.AWADDR(p.axi4_p.ADDR_WIDTH-1,ADDR_BURST_WIDTH_SZ)
          addr_low  := Cat(io.t.awreq.AWADDR(ADDR_BURST_WIDTH_SZ-1,ADDR_WIDTH_OFF), 
              Fill(ADDR_WIDTH_OFF,0.asUInt()))
          when (io.t.awreq.AWLEN >= 0.asUInt() && io.t.awreq.AWLEN <= 1.asUInt()) {
            wrap_mask := 1.asUInt()
          } .elsewhen (io.t.awreq.AWLEN >= 2.asUInt() && io.t.awreq.AWLEN <= 3.asUInt()) {
            wrap_mask := 3.asUInt()
          } .elsewhen (io.t.awreq.AWLEN >= 4.asUInt() && io.t.awreq.AWLEN <= 7.asUInt()) {
            wrap_mask := 7.asUInt()
          } .otherwise {
            wrap_mask := 15.asUInt()
          }
        } .otherwise {
          wrap_mask := Fill(ADDR_BURST_WIDTH_SZ, 1.asUInt()) // No mask
          addr_high := io.t.awreq.AWADDR(p.axi4_p.ADDR_WIDTH-1,ADDR_BURST_WIDTH_SZ)
          // Capture the entire low address
          addr_low  := io.t.awreq.AWADDR(ADDR_BURST_WIDTH_SZ-1,0)
        }
      }
    }
  }
  
  is (sWaitWbAck) {
    when (io.i.rsp.ACK) {
      wb_we_r := Bool(false)
      axi_dat_r_r := io.i.rsp.DAT_R
      access_state := sWaitAxiReadReady
    }
    
  }
  
  is (sWaitAxiReadReady) {
    when (io.t.rready) {
      when (count === length) {
        // We're done
        addr_high := 0.asUInt()
        addr_low := 0.asUInt()
        access_state := sWaitReq
      } .otherwise {
        count := count + 1.asUInt()
        addr_low := ((addr_low & (wrap_mask ^ ADDR_BURST_MASK)) | 
            ((addr_low + DATA_WORD_SIZE) & (wrap_mask & ADDR_BURST_MASK)))
            
        // Go back around for another access
        access_state := sWaitWbAck
      }
    }
  }
  
  is (sWaitAxiWriteData) {
    when (io.t.wreq.WVALID) {
      wb_dat_w_r := io.t.wreq.WDATA
      axi_dat_last_r := io.t.wreq.WLAST
      access_state := sWaitAxiWriteData2
    }
  }
  
  is (sWaitAxiWriteData2) {
    when (io.i.rsp.ACK) {
      when (axi_dat_last_r) {
        access_state := sSendWriteResponse
      } .otherwise {
        addr_low := ((addr_low & (wrap_mask ^ ADDR_BURST_MASK)) | 
            ((addr_low + DATA_WORD_SIZE) & (wrap_mask & ADDR_BURST_MASK)))
        access_state := sWaitAxiWriteData
      }
    }
  }
  
  is (sSendWriteResponse) {
    when (io.t.bready) {
      access_state := sWaitReq
    }
  }
  }
  
  // assignments first
  io.i.req.TGA := 0.asUInt()
  io.i.req.TGD_W := 0.asUInt()
  io.i.req.TGC := 0.asUInt()
  io.i.req.CTI := 0.asUInt()
  io.i.req.BTE := 0.asUInt()
  
  io.i.req.ADR := Cat(addr_high, addr_low)
  io.i.req.WE := wb_we_r
  io.i.req.SEL := wb_sel_r
  io.i.req.CYC := (access_state === sWaitWbAck || access_state === sWaitAxiWriteData2)
  io.i.req.STB := io.i.req.CYC
  io.t.rresp.RRESP := 0.asUInt() // TODO: should signal an error on WB error
  io.t.rresp.RDATA := axi_dat_r_r
  io.t.rresp.RVALID := (access_state === sWaitAxiReadReady)
  io.t.rresp.RLAST := (access_state === sWaitAxiReadReady && count === length)
  io.t.rresp.RID := axi_id_r
  
  io.t.arready := (access_state === sWaitReq)
  io.t.awready := (access_state === sWaitReq && io.t.arreq.ARVALID === Bool(false))
  
  io.t.wready := (access_state === sWaitAxiWriteData)
  io.i.req.DAT_W := wb_dat_w_r
  
  io.t.brsp.BVALID := (access_state === sSendWriteResponse)
  io.t.brsp.BID := axi_id_r
  io.t.brsp.BRESP := 0.asUInt()
}

object Axi4WishboneBridge {
  class Parameters(
    val axi4_p : AXI4.Parameters,
    val wb_p   : Wishbone.Parameters,
    val little_endian : Bool = Bool(true)
    ) { }
}