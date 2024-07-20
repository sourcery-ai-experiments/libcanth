ifndef __libcanth_arg_mk_included__
override __libcanth_arg_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:arg.mk=internal.mk))

override __default_O = $(THIS_DIR)

$(call arg_var,O)
$(eval override O=$$(eval override O:=$$$$(patsubst\
 //,/,$$$$(or $$$$(realpath $(value O)),$$$$(error \
 Output directory "$(value O)" does not exist))/))$$O)

$(call arg_var,PKG_CONFIG,pkg-config)

$(call arg_bool_var,debug)
$(call arg_bool_var,Q)
$(call arg_bool_var,V)

ifdef V
  override undefine Q
  override undefine nop
else
  override nop := @:
endif

ifeq (,$Q)
  override SGR      = $(shell printf '\e[$1m%s\e[m' '$2')
  override fyi      = $(if $2,$(info $($1_pfx)$2))
  override .fyi     = $(call pfx-if,$w$w$w$w,$(strip $1))
  override two-info = $(eval override $1 = \
    $$(if                                  \
      $$(filter undefined,$$(origin $1)),, \
      $$(eval override undefine $1)$$(call \
        fyi,INFO,$$(call .fyi,$$1))$$(call \
        fyi,INFO,$$(call .fyi,$$2))))

  override CLEAN_pfx   = $(eval override CLEAN_pfx   := $$(call SGR,0;35,CLEAN   ))$(CLEAN_pfx)
  override CC_pfx      = $(eval override CC_pfx      := $$(call SGR,0;36,CC      ))$(CC_pfx)
  override CXX_pfx     = $(eval override CXX_pfx     := $$(call SGR,0;36,CXX     ))$(CXX_pfx)
  override INFO_pfx    = $(eval override INFO_pfx    := $$(call SGR,38;5;213,INFO))$(INFO_pfx)
  override INSTALL_pfx = $(eval override INSTALL_pfx := $$(call SGR,1;36,INSTALL ))$(INSTALL_pfx)
  override LINK_pfx    = $(eval override LINK_pfx    := $$(call SGR,1;34,LINK    ))$(LINK_pfx)
  override STRIP_pfx   = $(eval override STRIP_pfx   := $$(call SGR,0;33,STRIP   ))$(STRIP_pfx)
  override SYMLINK_pfx = $(eval override SYMLINK_pfx := $$(call SGR,0;32,SYMLINK ))$(SYMLINK_pfx)
  override YEET_pfx    = $(eval override YEET_pfx    := $$(call SGR,38;5;191,YEET))$(YEET_pfx)
else
  override undefine two-info
  override undefine .fyi
  override undefine fyi
endif

ifeq (,$Q$V)
  override Y_ := (╯°□°）╯︵ ┻━┻
  override Y__ = $(call SGR,38;5;119,    $(Y_))
  override msg = $(info $($1_pfx)$2)
else
  override undefine Y__
  override undefine msg
endif

ifndef V
  override Q := @
endif

endif
