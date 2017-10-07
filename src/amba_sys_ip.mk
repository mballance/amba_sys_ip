
AMBA_SYS_IP_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

AMBA_SYS_IP_LIB := amba_sys_ip_lib.jar
AMBA_SYS_IP_DEPS = $(STD_PROTOCOL_IF_LIB) $(CHISELLIB_JAR) $(SV_BFMS_JAR)
AMBA_SYS_IP_LIBS = $(AMBA_SYS_IP_LIB) $(AMBA_SYS_IP_DEPS)
AMBA_SYS_IP_SRC := \
  $(wildcard $(AMBA_SYS_IP_SRC_DIR)/amba_sys_ip/axi4/*.scala) \
  $(wildcard $(AMBA_SYS_IP_SRC_DIR)/amba_sys_ip/axi4/ve/*.scala)

else # Rules

$(AMBA_SYS_IP_LIB) : $(AMBA_SYS_IP_SRC) $(AMBA_SYS_IP_DEPS)
	echo "Compile: $^"
	$(Q)$(DO_CHISELC)
	
Axi4SramTB.v : $(AMBA_SYS_IP_LIBS)
	echo "Generate: $^"
	$(Q)$(DO_CHISELG) amba_sys_ip.axi4.ve.Axi4SramTBGen

endif

