package amba_sys_ip.axi4.ve

import chisel3._
import sv_bfms.axi4.Axi4MasterAgent
import amba_sys_ip.axi4.AXI4_IC
import std_protocol_if.AXI4
import sv_bfms.axi4.builtin.Axi4BuiltinMasterAgent
import sv_bfms.axi4.builtin.Axi4BuiltinSlaveAgent

class Axi4InterconnectTB extends Module {
  
  val io = IO(new Bundle {
    // No external ports
  })

  val p = new AXI4.Parameters(32, 32)
  val u_m0 = Module(new Axi4BuiltinMasterAgent(p))
  val u_m1 = Module(new Axi4BuiltinMasterAgent(p))
  val u_s0 = Module(new Axi4BuiltinSlaveAgent(p))
  val u_s1 = Module(new Axi4BuiltinSlaveAgent(p))
  
  val u_dut = Module(new AXI4_IC(new AXI4_IC.Parameters(2, 2, 
      new AXI4.Parameters(ADDR_WIDTH=32, DATA_WIDTH=32)))
  )
  
  u_dut.io.m(0) <> u_m0.io.i
  u_dut.io.m(1) <> u_m1.io.i
  u_dut.io.s(0) <> u_s0.io.t
  u_dut.io.s(1) <> u_s1.io.t
  
  u_dut.io.addr_base(0) := 0x00000000.asUInt()
  u_dut.io.addr_limit(0) := 0x0000FFFF.asUInt()
  u_dut.io.addr_base(1) := 0x00001000.asUInt()
  u_dut.io.addr_limit(1) := 0x0001FFFF.asUInt()
  
 
  
}

object Axi4InterconnectTBGen extends App {
  chisel3.Driver.execute(args, () =>
    new Axi4InterconnectTB()
  );
}

