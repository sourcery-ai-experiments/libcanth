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

endif
