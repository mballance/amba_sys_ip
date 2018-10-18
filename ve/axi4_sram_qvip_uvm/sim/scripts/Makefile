
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

#MK_INCLUDES += $(SV_BFMS)/src/sv_bfms.mk
MK_INCLUDES += $(AMBA_SYS_IP)/mkfiles/amba_sys_ip.mk
#MK_INCLUDES += $(CHISELSCRIPTS)/mkfiles/chiselscripts.mk
#MK_INCLUDES += $(CHISELLIB)/src/chisellib.mk
#MK_INCLUDES += $(AMBA_SYS_IP)/subprojects/std_protocol_if/src/std_protocol_if.mk

BUILD_PRECOMPILE_TARGETS += Axi4SramTB.v

TB=axi4_sram_tb
TB_MODULES=Axi4SramTB Axi4SramHvlTB axi4_sram_tests_pkg

include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk

include $(PACKAGES_DIR)/packages.mk


	
