ifndef __libcanth_cc_mk_included__
override __libcanth_cc_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:cc.mk=internal.mk))

$(call arg_var,CC, gcc)
$(call arg_var,CXX,g++)

$(call import-macros, \
  cc-id-macros,       \
  __GNUC__            \
  __GNUC_MINOR__      \
  __GNUC_PATCHLEVEL__ \
  __clang_major__     \
  __clang_minor__     \
  __clang_patchlevel__)

__clang__ = $(eval override $(if $(__clang_major__),__clang__:=1,undefine __clang__))$(__clang__)
cc_major  = $(eval override cc_major := $$(or $$(__clang_major__),$$(__GNUC__)))$(cc_major)
cc_minor  = $(eval override cc_minor := $$(or $$(__clang_minor__),$$(__GNUC_MINOR__)))$(cc_minor)
cc_patch  = $(eval override cc_patch := $$(or $$(__clang_patchlevel__),$$(__GNUC_PATCHLEVEL__)))$(cc_patch)
cc_kind   = $(eval override cc_kind  := $$(if $$(__clang__),Clang,GCC))$(cc_kind)
cc_id     = $(eval override cc_id    := $$(cc_kind) $$(cc_major).$$(cc_minor).$$(cc_patch))$(cc_id)

override __default_CFLAGS = $(if $(ARCH),-march=$(ARCH)) \
  $(if $(CPU),-mcpu=$(CPU)) $(if $(TUNE),-mtune=$(TUNE)) \
  -O$(if $(DEBUG),$(if $(USE_CLANG),0,g) -ggdb3,2) -pipe \
  -flto=$(if $(USE_CLANG),full,auto)

override __default_CPPFLAGS  = $(if $(DEBUG),,-DNDEBUG)
override __default_CXXFLAGS  = $(__default_CFLAGS)
override __default_USE_CLANG = $(__clang__)

$(call arg_var,CPU)
$(call arg_var,DEBUG)
$(call arg_var,ARCH,native)
$(call arg_var,TUNE,native)
$(call arg_var,CSTD,gnu23)
$(call arg_var,CXXSTD,gnu++23)
$(call arg_var,USE_CLANG)
$(call arg_var,CFLAGS)
$(call arg_var,CPPFLAGS)
$(call arg_var,CXXFLAGS)
$(call arg_var,WARNFLAGS,-Wall -Wextra -pedantic)

override C_BUILDFLAGS   = -std=$(CSTD) $(CFLAGS) $(CPPFLAGS) $(WARNFLAGS)
override CXX_BUILDFLAGS = -std=$(CXXSTD) $(CXXFLAGS) $(CPPFLAGS) $(WARNFLAGS)

endif
