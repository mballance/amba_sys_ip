
+incdir+${SIM_DIR_A}/../tb
+incdir+${SIM_DIR_A}/../tests

// Files to add for AXI4 QVIP
+incdir+${QUESTA_MVC_HOME}/questa_mvc_src/sv
+incdir+${QUESTA_MVC_HOME}/questa_mvc_src/sv/axi4
${QUESTA_MVC_HOME}/include/questa_mvc_svapi.svh
${QUESTA_MVC_HOME}/questa_mvc_src/sv/mvc_pkg.sv
${QUESTA_MVC_HOME}/questa_mvc_src/sv/axi4/mgc_axi4_v1_0_pkg.sv
${SV_BFMS}/axi4/uvm/qvip/axi4_qvip_master.sv
// /Files to add for AXI4 QVIP


${AMBA_SYS_IP}/rtl/axi4/axi4_sram/axi4_sram.sv
${AMBA_SYS_IP}/rtl/axi4/axi4_sram_bridges/axi4_generic_byte_en_sram_bridge.sv

${STD_PROTOCOL_IF}/rtl/axi4/axi4_if.sv
${STD_PROTOCOL_IF}/rtl/memory/generic_sram_byte_en_if.sv

-f ${MEMORY_PRIMITIVES}/rtl/rtl_w.f
-f ${MEMORY_PRIMITIVES}/rtl/sim/sim.f

${SIM_DIR_A}/../tb/Axi4SramEnvBasePkg.sv
${SIM_DIR_A}/../tests/Axi4SramTestsBasePkg.sv
${BUILD_DIR_A}/Axi4SramTB.v
${SIM_DIR_A}/../tb/Axi4SramHvlTB.sv

// User testbench
${SIM_DIR_A}/../tb/axi4_sram_env_pkg.sv
${SIM_DIR_A}/../tests/axi4_sram_tests_pkg.sv


