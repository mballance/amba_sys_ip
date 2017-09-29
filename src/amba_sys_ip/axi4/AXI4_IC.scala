package amba_sys_ip.axi4

import chisel3._
import std_protocol_if._
import chisellib.Plusargs
import std_protocol_if.AXI4._

class AXI4_IC(p : AXI4_IC.Parameters) extends Module {
  val N_MASTER_ID_BITS = if (p.N_MASTERS > 1) 
    util.log2Ceil(p.N_MASTERS) else 1
  val TARGET_ID_BITS = p.axi4_p.ID_WIDTH+N_MASTER_ID_BITS
  
  def master_id(id : UInt) = {
     id(p.axi4_p.ID_WIDTH+N_MASTER_ID_BITS-1, p.axi4_p.ID_WIDTH)
  }
  
  println("TARGET_ID_BITS=" + TARGET_ID_BITS)
  
  val targetParameters = new AXI4.Parameters(
      p.axi4_p.ADDR_WIDTH,
      p.axi4_p.DATA_WIDTH,
      TARGET_ID_BITS
      );
  
  val io = IO(new Bundle {
    val addr_base = Input(Vec(p.N_SLAVES, UInt(p.axi4_p.ADDR_WIDTH.W)))
    val addr_limit = Input(Vec(p.N_SLAVES, UInt(p.axi4_p.ADDR_WIDTH.W)))
    val m = Vec(p.N_MASTERS, Flipped(new AXI4(p.axi4_p)))
    val s = Vec(p.N_SLAVES, new AXI4(targetParameters))
  })

  // Creates a target manager for each target device
  val targets = Seq.fill(p.N_SLAVES) (Module(new AXI4_IC.Target(p)))
  
  // Connect the requests to all target managers
  targets.foreach(t => io.m.map(_.awreq).zip(t.io.awreq).map(i => i._1 <> i._2))
  targets.foreach(t => io.m.map(_.arreq).zip(t.io.arreq).map(i => i._1 <> i._2))
  targets.foreach(t => io.m.map(_.wreq).zip(t.io.wreq).map(i => i._1 <> i._2))
 
  // Connect a target interface to each target manager
  io.s.zip(targets.map(_.io.s)).map(ss => ss._1 <> ss._2)
  
  // Connect the addr base and limit to each target manager
  io.addr_base.zip(targets).map(ss => ss._2.io.addr_base := ss._1)
  io.addr_limit.zip(targets).map(ss => ss._2.io.addr_limit := ss._1)
}

object AXI4_IC {
  class Parameters(
      val N_MASTERS : Int = 2,
      val N_SLAVES  : Int = 2,
      val axi4_p    : AXI4.Parameters) { } 
  
  class ResponseMgr(val p : Parameters) extends Module {
    val io = IO(new Bundle {
      val brsp = Flipped(new AXI4.BRsp(p.axi4_p))
    })
  }

  class Target(
      val p : Parameters) extends Module {
    val io = IO(new Bundle {
      val s = new AXI4(p.axi4_p)
      val awreq = Vec(p.N_MASTERS, Flipped(new AWReq(p.axi4_p)))
      val arreq = Vec(p.N_MASTERS, Flipped(new ARReq(p.axi4_p)))
      val wreq = Vec(p.N_MASTERS, Flipped(new WReq(p.axi4_p)))
      val addr_base = Input(UInt(p.axi4_p.ADDR_WIDTH.W))
      val addr_limit = Input(UInt(p.axi4_p.ADDR_WIDTH.W))
    })
    
    // Read-request management
    
    // TODO: Writes have a cascading effect. Accepting a write
    //       from an initiator reserves the target write-data
    //       channel for the same initiator
    
    // Create an array of per-master selects
    val m_aw_sel = io.awreq.map(_.AWADDR).map(addr => 
      (addr >= io.addr_base && addr <= io.addr_limit))
    val m_ar_sel = io.arreq.map(_.ARADDR).map(addr => 
      (addr >= io.addr_base && addr <= io.addr_limit))

    io.s.arreq.ARVALID := m_ar_sel.reduceLeft(_ | _)
    io.s.awreq.AWVALID := m_aw_sel.reduceLeft(_ | _)
  }
}

