
AMBA_SYS_IP_MKFILES_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
AMBA_SYS_IP_DIR := $(abspath $(AMBA_SYS_IP_MKFILES_DIR)..)

AMBA_SYS_IP := $(AMBA_SYS_IP_DIR)
export AMBA_SYS_IP

ifneq (1,$(RULES))

AMBA_SYS_IP_JAR := $(AMBA_SYS_IP_DIR)/lib/amba_sys_ip_lib.jar
AMBA_SYS_IP_DEPS = $(STD_PROTOCOL_IF_JARS) $(CHISELLIB_JARS) $(SV_BFMS_JARS)
AMBA_SYS_IP_JARS = $(AMBA_SYS_IP_JAR) $(AMBA_SYS_IP_DEPS)

else # Rules

Axi4SramTB.v : $(AMBA_SYS_IP_JARS)
	$(Q)$(DO_CHISELG) amba_sys_ip.axi4.ve.Axi4SramTBGen

Axi4InterconnectTB/Axi4InterconnectTB.f : $(AMBA_SYS_IP_JARS)
	$(Q)$(DO_CHISELG) -outdir `dirname $@` amba_sys_ip.axi4.ve.Axi4InterconnectTBGen

endif

