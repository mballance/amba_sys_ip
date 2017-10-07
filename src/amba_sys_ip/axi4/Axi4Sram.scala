package amba_sys_ip.axi4
import chisel3._
import chisel3.experimental._
import std_protocol_if._
import chisel3.core.Param
import chisellib.blackbox.SourceAnnotator

class Axi4Sram(val p : Axi4Sram.Parameters) extends Module {
  
  val io = IO(new Bundle {
    val s = Flipped(new AXI4(p.axi4_p))
  });
  
//  io.s.tieoff()
  

  val core = Module(new axi4_sram(p))
 
  core.io.clk := clock
  core.io.rst := reset
  core.io.AWADDR := io.s.awreq.AWADDR
  core.io.AWID := io.s.awreq.AWID
  core.io.AWLEN := io.s.awreq.AWLEN
  core.io.AWSIZE := io.s.awreq.AWSIZE
  core.io.AWBURST := io.s.awreq.AWBURST
  core.io.AWLOCK := io.s.awreq.AWLOCK
  core.io.AWCACHE := io.s.awreq.AWCACHE
  core.io.AWPROT := io.s.awreq.AWPROT
  core.io.AWQOS := io.s.awreq.AWQOS
  core.io.AWREGION := io.s.awreq.AWREGION
  core.io.AWVALID := io.s.awreq.AWVALID
  io.s.awready := core.io.AWREADY

  core.io.WDATA := io.s.wreq.WDATA
  core.io.WSTRB := io.s.wreq.WSTRB
  core.io.WLAST := io.s.wreq.WLAST
  core.io.WVALID := io.s.wreq.WVALID
  io.s.wready := core.io.WREADY

  io.s.brsp.BID := core.io.BID
  io.s.brsp.BRESP := core.io.BRESP
  io.s.brsp.BVALID := core.io.BVALID
  core.io.BREADY := io.s.bready

  core.io.ARADDR := io.s.arreq.ARADDR
  core.io.ARID := io.s.arreq.ARID
  core.io.ARLEN := io.s.arreq.ARLEN
  core.io.ARSIZE := io.s.arreq.ARSIZE
  core.io.ARBURST := io.s.arreq.ARBURST
  core.io.ARLOCK := io.s.arreq.ARLOCK
  core.io.ARCACHE := io.s.arreq.ARCACHE
  core.io.ARPROT := io.s.arreq.ARPROT
  core.io.ARQOS := io.s.arreq.ARQOS
  core.io.ARREGION := io.s.arreq.ARREGION
  core.io.ARVALID := io.s.arreq.ARVALID
  io.s.arready := core.io.ARREADY

  io.s.rresp.RID := core.io.RID
  io.s.rresp.RDATA := core.io.RDATA
  io.s.rresp.RRESP := core.io.RRESP
  io.s.rresp.RLAST := core.io.RLAST
  io.s.rresp.RVALID := core.io.RVALID
  core.io.RREADY := io.s.rready
 
}

  class axi4_sram(val p : Axi4Sram.Parameters) extends BlackBox(
      Map("MEM_ADDR_BITS" -> p.MEM_ADDR_BITS.toInt,
          "AXI_ADDRESS_WIDTH" -> p.axi4_p.ADDR_WIDTH.toInt,
          "AXI_DATA_WIDTH" -> p.axi4_p.DATA_WIDTH.toInt,
          "AXI_ID_WIDTH" -> p.axi4_p.ID_WIDTH.toInt,
          "INIT_FILE" -> p.INIT_FILE)) with SourceAnnotator {
    val io = IO(new Bundle {
      val clk = Input(Clock())
      val rst = Input(Bool())
			val AWADDR = Input(UInt(p.axi4_p.ADDR_WIDTH.W))
			val AWID = Input(UInt(p.axi4_p.ID_WIDTH.W))
			val AWLEN = Input(UInt(8.W))
			val AWSIZE = Input(UInt(3.W))
			val AWBURST = Input(UInt(2.W))
			val AWLOCK = Input(Bool())
			val AWCACHE = Input(UInt(4.W))
			val AWPROT = Input(UInt(3.W))
			val AWQOS = Input(UInt(4.W))
			val AWREGION = Input(UInt(4.W))
			val AWVALID = Input(Bool())
			val AWREADY = Output(Bool())
			
			val WDATA = Input(UInt(p.axi4_p.DATA_WIDTH.W))
			val WSTRB = Input(UInt((p.axi4_p.DATA_WIDTH/8).W))
			val WLAST = Input(Bool())
			val WVALID = Input(Bool())
			val WREADY = Output(Bool())

			val BID = Output(UInt(p.axi4_p.ID_WIDTH.W))
			val BRESP = Output(UInt(2.W))
			val BVALID = Output(Bool())
			val BREADY = Input(Bool())

			val ARID = Input(UInt(p.axi4_p.ID_WIDTH.W))
			val ARADDR = Input(UInt(p.axi4_p.ADDR_WIDTH.W))
			val ARLEN = Input(UInt(8.W))
			val ARSIZE = Input(UInt(3.W))
			val ARBURST = Input(UInt(2.W))
			val ARLOCK = Input(Bool())
			val ARCACHE = Input(UInt(4.W))
			val ARPROT = Input(UInt(3.W))
			val ARQOS = Input(UInt(4.W))
			val ARREGION = Input(UInt(4.W))
			val ARVALID = Input(Bool())
			val ARREADY = Output(Bool())
		
			val RID = Output(UInt(p.axi4_p.ID_WIDTH.W))
			val RDATA = Output(UInt(p.axi4_p.DATA_WIDTH.W))
			val RRESP = Output(UInt(2.W))
			val RLAST = Output(Bool())
			val RVALID = Output(Bool())
			val RREADY = Input(Bool())
    });
    
    // Required sources
    source(this, "${AMBA_SYS_IP}/axi4/axi4_sram/axi4_sram.sv")
  }

object Axi4Sram {
  class Parameters(
      val MEM_ADDR_BITS : Int = 10,
      val axi4_p : AXI4.Parameters,
      val INIT_FILE : String = ""
      ) { }
  

  }
  