package amba_sys_ip.axi4.ve

import chisel3._
import amba_sys_ip.axi4.Axi4Sram
import std_protocol_if.AXI4
import sv_bfms.axi4.qvip.Axi4QvipMasterAgent
import sv_bfms.axi4.Axi4MasterAgent
import chisel3.core.BaseModule

class Axi4SramTB extends Module {
  
  val io = IO(new Bundle {
    
  })

  val axi4_p = new AXI4.Parameters(32, 32, 4)
  
  val sram = IntrospectModule(new Axi4Sram(
      new Axi4Sram.Parameters(MEM_ADDR_BITS=10, axi4_p))
  )
  
  val axi4_qvip = Axi4MasterAgent(axi4_p)
  
  sram.io.s <> axi4_qvip.io.i
}

object IntrospectModule {
  def apply[T <: BaseModule](m : => T): T = {
    val mv = Module(m)
    mv
  }
}

object Axi4SramTBGen extends App {
  chisel3.Driver.execute(args, () => new Axi4SramTB)
}