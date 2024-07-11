ifndef __libcanth_arg_mk_included__
override __libcanth_arg_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:arg.mk=internal.mk))

override __default_O = $(THIS_DIR)

$(call arg_var,DEBUG)
$(call arg_var,O)
$(call arg_var,PKG_CONFIG,pkg-config)
$(call arg_var,Q)
$(call arg_var,V)

$(eval override O=$$(eval override O:=$$$$(patsubst\
 //,/,$$$$(or $$$$(realpath $(value O)),$$$$(error \
 Output directory "$(value O)" does not exist))/))$$O)

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

ifeq (,$(strip $Q$V))
  override Y_ := (╯°□°）╯︵ ┻━┻
  override Y__ = $(call SGR,38;5;119,    $(Y_))
  override SGR = $(shell printf '\e[$1m%s\e[m' '$2')
  override msg = $(info $($1_pfx)$2)

  override CLEAN_pfx   = $(eval override CLEAN_pfx   := $$(call SGR,0;35,CLEAN   ))$(CLEAN_pfx)
  override COMPILE_pfx = $(eval override COMPILE_pfx := $$(call SGR,0;36,COMPILE ))$(COMPILE_pfx)
  override INSTALL_pfx = $(eval override INSTALL_pfx := $$(call SGR,1;36,INSTALL ))$(INSTALL_pfx)
  override LINK_pfx    = $(eval override LINK_pfx    := $$(call SGR,1;34,LINK    ))$(LINK_pfx)
  override STRIP_pfx   = $(eval override STRIP_pfx   := $$(call SGR,0;33,STRIP   ))$(STRIP_pfx)
  override SYMLINK_pfx = $(eval override SYMLINK_pfx := $$(call SGR,0;32,SYMLINK ))$(SYMLINK_pfx)
  override YEET_pfx    = $(eval override YEET_pfx    := $$(call SGR,38;5;191,YEET))$(YEET_pfx)
else
  override undefine Y__
  override undefine msg
endif

ifndef V
  override Q := @
endif

endif
