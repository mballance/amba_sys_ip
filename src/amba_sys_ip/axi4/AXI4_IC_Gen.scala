package amba_sys_ip.axi4

import chisellib.Plusargs
import std_protocol_if.AXI4
import chisel3._

object AXI4_IC_Gen extends App {
  val plusargs = Plusargs(args)
 
  var N_MASTERS = 1
  var N_SLAVES  = 2
  var ADDR_WIDTH = 32
  var DATA_WIDTH = 32
  
  chisel3.Driver.execute(args, () => 
    new AXI4_IC(
      new AXI4_IC.Parameters(
        N_MASTERS,
        N_SLAVES,
        new AXI4.Parameters(ADDR_WIDTH, DATA_WIDTH)
      )
  ))
}
