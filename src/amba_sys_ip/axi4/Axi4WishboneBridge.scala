package amba_sys_ip.axi4

import chisel3._
import chisel3.util._
import std_protocol_if._

class Axi4WishboneBridge(
    val axi4_p : AXI4.Parameters,
    val wb_p : Wishbone.Parameters) extends Module {
 
  require(axi4_p.ADDR_WIDTH == wb_p.ADDR_WIDTH,
      s"ADDR_WIDTH mismatch: AXI4=${axi4_p.ADDR_WIDTH} Wishbone=${wb_p.ADDR_WIDTH}")
  require(axi4_p.DATA_WIDTH == wb_p.DATA_WIDTH,
      s"DATA_WIDTH mismatch: AXI4=${axi4_p.DATA_WIDTH} Wishbone=${wb_p.DATA_WIDTH}")
  
  val io = IO(new Bundle {
    val t = Flipped(new AXI4(axi4_p))
    val i = new Wishbone(wb_p)
  })
 
  val sWaitReq :: sWaitWbAck :: sWaitAxiReadReady :: sWaitAxiWriteData :: sWaitAxiWriteData2 :: sSendWriteResponse :: Nil = Enum(6)
  val access_state = RegInit(sWaitReq)

  val wb_adr_r = RegInit(init = UInt(0, wb_p.ADDR_WIDTH.W))
  val wb_we_r = RegInit(init = Bool(false))
  val wb_sel_r = RegInit(init = UInt(0, (wb_p.DATA_WIDTH/8).W))
  val axi_len_r = RegInit(init = UInt(0, 8.W))
  val axi_id_r = RegInit(init = UInt(0, axi4_p.ID_WIDTH.W))
  val axi_dat_r_r = RegInit(init = UInt(0, axi4_p.DATA_WIDTH.W))
  val wb_dat_w_r = RegInit(init = UInt(0, axi4_p.DATA_WIDTH.W))
  val axi_dat_last_r = RegInit(init = Bool(false))
 
  switch (access_state) {
  is (sWaitReq) {
    when (io.t.arreq.ARVALID && io.t.arready) {
      wb_adr_r := io.t.arreq.ARADDR
      wb_we_r := Bool(false)
      wb_sel_r := 0xFFFF.asUInt() // all set
      axi_len_r := io.t.arreq.ARLEN
      axi_id_r := io.t.arreq.ARID
      access_state := sWaitWbAck
    } .otherwise {
      when (io.t.awreq.AWVALID && io.t.awready) {
        wb_adr_r := io.t.awreq.AWADDR
        wb_we_r := Bool(true)
        axi_id_r := io.t.awreq.AWID
        access_state := sWaitAxiWriteData
      }
    }
  }
  
  is (sWaitWbAck) {
    when (io.i.rsp.ACK) {
      wb_adr_r := 0.asUInt()
      wb_we_r := Bool(false)
      axi_dat_r_r := io.i.rsp.DAT_R
      access_state := sWaitAxiReadReady
    }
    
  }
  
  is (sWaitAxiReadReady) {
    when (io.t.rready) {
      access_state := sWaitReq
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
  io.i.req.ADR := wb_adr_r
  io.i.req.WE := wb_we_r
  io.i.req.SEL := wb_sel_r
  io.i.req.CYC := (access_state === sWaitWbAck || access_state === sWaitAxiWriteData2)
  io.i.req.STB := io.i.req.CYC
  io.t.rresp.RDATA := axi_dat_r_r
  io.t.rresp.RVALID := (access_state === sWaitAxiReadReady)
  io.t.rresp.RLAST := (access_state === sWaitAxiReadReady)
  io.t.rresp.RID := axi_id_r
  
  io.t.arready := (access_state === sWaitReq)
  io.t.awready := (access_state === sWaitReq && io.t.arreq.ARVALID === Bool(false))
  
  io.t.wready := (access_state === sWaitAxiWriteData)
  io.i.req.DAT_W := wb_dat_w_r
  
  io.t.brsp.BVALID := (access_state === sSendWriteResponse)
  io.t.brsp.BID := axi_id_r
}