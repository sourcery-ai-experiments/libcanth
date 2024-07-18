ifndef __libcanth_cc_mk_included__
override __libcanth_cc_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:cc.mk=arg.mk))

override __default_CPPFLAGS  = $(if $(debug),,-DNDEBUG)
override __default_WARNFLAGS = -Wall -Wextra -Wpedantic

$(call arg_var,CC,gcc)
$(call arg_var,CPPFLAGS)
$(call arg_var,CXX,g++)
$(call arg_var,WARNFLAGS)

$(call arg_var,arch)
$(call arg_var,cpu)
$(call arg_var,std)
$(call arg_var,tune)

$(call arg_bool_var,no_color)
$(call arg_bool_var,use_clang)

$(call import-macros,     \
  c, $(CC) -E -xc,        \
  __APPLE__               \
  __GNUC__                \
  __GNUC_MINOR__          \
  __GNUC_PATCHLEVEL__     \
  __apple_build_version__ \
  __clang_major__         \
  __clang_minor__         \
  __clang_patchlevel__,   \
  __default_c_arch        \
  __default_c_cpu         \
  __default_c_std         \
  __default_c_tune        \
  __default_c_no_va_opt   \
)
$(call arg_var,c_arch)
$(call arg_var,c_cpu)
$(call arg_var,c_std)
$(call arg_var,c_tune)

$(call arg_bool_var,c_no_va_opt)

override __default_use_cclang = $(or $(use_clang),$(if $(c__clang_major__),1))
$(call arg_bool_var,use_cclang)
$(if $(DEBUG_MK),$(info use_cclang="$(use_cclang)"))

override __default_CWARNFLAGS   = \
  $(if $(use_cclang),             \
    -Weverything                  \
    $(addprefix -Wno-,            \
      c++98-compat                \
      c++98-compat-pedantic       \
      declaration-after-statement \
      disabled-macro-expansion    \
      pre-c11-compat              \
      pre-c23-compat              \
      pre-c2x-compat              \
      unknown-warning-option      \
      unsafe-buffer-usage         \
))
$(call arg_var,CWARNFLAGS)

$(call import-macros,     \
  cxx, $(CXX) -E -xc++,   \
  __APPLE__               \
  __GNUC__                \
  __GNUC_MINOR__          \
  __GNUC_PATCHLEVEL__     \
  __apple_build_version__ \
  __clang_major__         \
  __clang_minor__         \
  __clang_patchlevel__,   \
  __default_cxx_arch      \
  __default_cxx_cpu       \
  __default_cxx_std       \
  __default_cxx_tune      \
)
$(call arg_var,cxx_arch)
$(call arg_var,cxx_cpu)
$(call arg_var,cxx_std)
$(call arg_var,cxx_tune)

override __default_use_cxxclang = $(or $(use_clang),$(if $(cxx__clang_major__),1))
$(call arg_bool_var,use_cxxclang)
$(if $(DEBUG_MK),$(info use_cxxclang="$(use_cxxclang)"))

override __default_CXXWARNFLAGS = \
  $(if $(use_cxxclang),           \
    -Weverything                  \
    $(addprefix -Wno-,            \
      c++98-compat                \
      c++98-compat-pedantic       \
      declaration-after-statement \
      disabled-macro-expansion    \
      pre-c11-compat              \
      pre-c23-compat              \
      pre-c2x-compat              \
      unknown-warning-option      \
      unsafe-buffer-usage         \
))
$(call arg_var,CXXWARNFLAGS)

override __default_no_lto = $(filter-out 11,$(use_cclang)$(use_cxxclang))
$(call arg_bool_var,no_lto)
$(if $(DEBUG_MK),$(info no_lto="$(no_lto)"))

override __default_CFLAGS = $(if $(c_arch),-march=$(c_arch)) $(if $(c_cpu),-mcpu=$(c_cpu)) \
  $(if $(c_tune),-mtune=$(c_tune)) -O$(if $(debug),$(if $(use_cclang),0,g) -ggdb3,2)   \
  $(if $(no_color),,$(if $(use_cclang),-fcolor-diagnostics))                       \
  $(if $(no_lto),,-flto=$(if $(use_cclang),full,auto)) -pipe
$(call arg_var,CFLAGS)

override __default_CXXFLAGS = $(if $(cxx_arch),-march=$(cxx_arch)) $(if $(cxx_cpu),-mcpu=$(cxx_cpu)) \
  $(if $(cxx_tune),-mtune=$(cxx_tune)) -O$(if $(debug),$(if $(use_cxxclang),0,g) -ggdb3,2)   \
  $(if $(no_color),,$(if $(use_cxxclang),-fcolor-diagnostics))                        \
  $(if $(no_lto),,-flto=$(if $(use_cxxclang),full,auto)) -pipe
$(call arg_var,CXXFLAGS)

override C_BUILDFLAGS = $(eval \
  override C_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(c_std)) \
  $$(CFLAGS) $$(CPPFLAGS) $$(if $$(c_no_va_opt),-DNO_VA_OPT=1) $$(WARNFLAGS) \
  $$(CWARNFLAGS)))$(C_BUILDFLAGS)

override CXX_BUILDFLAGS = $(eval \
  override CXX_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(cxx_std)) \
  $$(CXXFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CXXWARNFLAGS)))$(CXX_BUILDFLAGS)

override CC_id = $(eval override CC_id := $$(strip $$(if $$(c__clang_major__),\
  clang $$(c__clang_major__).$$(c__clang_minor__).$$(c__clang_patchlevel__),\
  gcc $$(c__GNUC__).$$(c__GNUC_MINOR__).$$(c__GNUC_PATCHLEVEL__))))$(CC_id)

override CXX_id = $(eval override CXX_id := $$(strip $$(if $$(cxx__clang_major__),\
  clang++ $$(cxx__clang_major__).$$(cxx__clang_minor__).$$(cxx__clang_patchlevel__),\
  g++ $$(cxx__GNUC__).$$(cxx__GNUC_MINOR__).$$(cxx__GNUC_PATCHLEVEL__))))$(CXX_id)

endif
