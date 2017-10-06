
include $(SIMSCRIPTS_DIR)/mkfiles/plusargs.mk

MK_INCLUDES += $(AMBA_SYS_IP)/ve/sv_bfms/src/sv_bfms.mk
MK_INCLUDES += $(AMBA_SYS_IP)/src/amba_sys_ip.mk
MK_INCLUDES += $(AMBA_SYS_IP)/chiselscripts/mkfiles/chiselscripts.mk
MK_INCLUDES += $(AMBA_SYS_IP)/subprojects/chisellib/src/chisellib.mk
MK_INCLUDES += $(AMBA_SYS_IP)/subprojects/std_protocol_if/src/std_protocol_if.mk

BUILD_PRECOMPILE_TARGETS += Axi4SramTB.v

TB=axi4_sram_tb
TB_MODULES=Axi4SramTB Axi4SramHvlTB axi4_sram_tests_pkg

include $(SIMSCRIPTS_DIR)/mkfiles/common_sim.mk


	