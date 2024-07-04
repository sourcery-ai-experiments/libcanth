ifneq (,$(strip $(THIS_DIR)))
ifndef __libcanth_common_mk_included__
override __libcanth_common_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:common.mk=mk/cc.mk))

$(call arg_var,O,$(THIS_DIR))
$(call arg_var,PKG_CONFIG,pkg-config)

override O := $(O:/=)/

ifneq (1,$(strip $V))
  override undefine V
endif

ifdef V
  override undefine Q
  override undefine nop
else
  ifneq (1,$(strip $Q))
    override undefine Q
  endif
  override nop := @:
endif

ifeq (,$Q$V)
  override Y_ := (╯°□°）╯︵ ┻━┻
  override Y__ = $(call SGR,38;5;119,    $(Y_))
  override SGR = $(shell printf '\e[$1m%s\e[m' '$2')
  override msg = $(info $($1_pfx)$2)

  CLEAN_pfx   = $(eval CLEAN_pfx   := $$(call SGR,0;35,CLEAN   ))$(CLEAN_pfx)
  COMPILE_pfx = $(eval COMPILE_pfx := $$(call SGR,0;36,COMPILE ))$(COMPILE_pfx)
  INSTALL_pfx = $(eval INSTALL_pfx := $$(call SGR,1;36,INSTALL ))$(INSTALL_pfx)
  LINK_pfx    = $(eval LINK_pfx    := $$(call SGR,1;34,LINK    ))$(LINK_pfx)
  STRIP_pfx   = $(eval STRIP_pfx   := $$(call SGR,0;33,STRIP   ))$(STRIP_pfx)
  SYMLINK_pfx = $(eval SYMLINK_pfx := $$(call SGR,0;32,SYMLINK ))$(SYMLINK_pfx)
  YEET_pfx    = $(eval YEET_pfx    := $$(call SGR,38;5;191,YEET))$(YEET_pfx)
else
  override undefine Y__
  override undefine msg
endif

ifndef V
  override Q := @
endif

$(eval yeet:; $$(call msg,YEET,$$(Y__))@:)
.PHONY: yeet

endif
endif
