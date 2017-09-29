
AMBA_SYS_IP_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

AMBA_SYS_IP_LIB := amba_sys_ip_lib.jar
AMBA_SYS_IP_LIBS = $(AMBA_SYS_IP_LIB) $(STD_PROTOCOL_IF_LIB) $(CHISELLIB_JAR)
AMBA_SYS_IP_SRC := \
  $(wildcard $(AMBA_SYS_IP_SRC_DIR)/amba_sys_ip/axi4/*.scala)

else # Rules

$(AMBA_SYS_IP_LIB) : $(AMBA_SYS_IP_SRC) $(STD_PROTOCOL_IF_LIB) $(CHISELLIB_JAR)
	$(Q)$(CHISELC) -o $@ $(AMBA_SYS_IP_SRC) -L$(CHISELLIB_JAR) -L$(STD_PROTOCOL_IF_LIB)

endif

