ifndef __libcanth_cc_mk_included__
override __libcanth_cc_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:cc.mk=arg.mk))

override __default_CPPFLAGS  = $(if $(debug),,-DNDEBUG)
override __default_WARNFLAGS = -Wall -Wextra -Wpedantic

$(call arg_var,arch,native)
$(call arg_var,CC,gcc)
$(call arg_var,CPPFLAGS)
$(call arg_var,cpu)
$(call arg_var,CXX,g++)
$(call arg_var,tune,native)
$(call arg_var,WARNFLAGS)

$(call arg_bool_var,no_color)
$(call arg_bool_var,use_clang)

$(call import-macros,                   \
  cc, $(CC) -E -xc,                     \
  __GNUC__                              \
  __GNUC_MINOR__                        \
  __GNUC_PATCHLEVEL__                   \
  __clang_major__                       \
  __clang_minor__                       \
  __clang_patchlevel__,                 \
  __default_cstd,                       \
  $(.ifdef) __clang_major__             \
    $(.if) __clang_major__ > 17         \
      $.override __default_cstd:=gnu23  \
    $(.elif) __clang_major__ > 8        \
      $.override __default_cstd:=gnu2x  \
    $(.endif)                           \
  $(.elif) __GNUC__ > 13                \
    $.override __default_cstd:=gnu23    \
  $(.elif) __GNUC__ > 8                 \
    $.override __default_cstd:=gnu2x    \
  $(.endif))
$(call arg_var,cstd)

override __default_use_cclang = $(or $(use_clang),$(if $(cc__clang_major__),1))
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

$(call import-macros,                      \
  cxx, $(CXX) -E -xc++,                    \
  __GNUC__                                 \
  __GNUC_MINOR__                           \
  __GNUC_PATCHLEVEL__                      \
  __clang_major__                          \
  __clang_minor__                          \
  __clang_patchlevel__,                    \
  __default_cxxstd,                        \
  $(.ifdef) __clang_major__                \
    $(.if) __clang_major__ > 16            \
      $.override __default_cxxstd:=gnu++23 \
    $(.elif) __clang_major__ > 11          \
      $.override __default_cxxstd:=gnu++2b \
    $(.elif) __clang_major__ > 9           \
      $.override __default_cxxstd:=gnu++20 \
    $(.elif) __clang_major__ > 4           \
      $.override __default_cxxstd:=gnu++2a \
    $(.endif)                              \
  $(.elif) __GNUC__ > 10                   \
    $.override __default_cxxstd:=gnu++23   \
  $(.elif) __GNUC__ > 9                    \
    $.override __default_cxxstd:=gnu++20   \
  $(.elif) __GNUC__ > 7                    \
    $.override __default_cxxstd:=gnu++2a   \
  $(.endif))
$(call arg_var,cxxstd)

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

override __default_CFLAGS = $(if $(arch),-march=$(arch)) $(if $(cpu),-mcpu=$(cpu)) \
  $(if $(tune),-mtune=$(tune)) -O$(if $(debug),$(if $(use_cclang),0,g) -ggdb3,2)   \
  $(if $(no_color),,$(if $(use_cclang),-fcolor-diagnostics))                       \
  $(if $(no_lto),,-flto=$(if $(use_cclang),full,auto)) -pipe
$(call arg_var,CFLAGS)

override __default_CXXFLAGS = $(if $(arch),-march=$(arch)) $(if $(cpu),-mcpu=$(cpu)) \
  $(if $(tune),-mtune=$(tune)) -O$(if $(debug),$(if $(use_cxxclang),0,g) -ggdb3,2)   \
  $(if $(no_color),,$(if $(use_cxxclang),-fcolor-diagnostics))                        \
  $(if $(no_lto),,-flto=$(if $(use_cxxclang),full,auto)) -pipe
$(call arg_var,CXXFLAGS)

override C_BUILDFLAGS = $(eval \
  override C_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(cstd)) \
  $$(CFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CWARNFLAGS)))$(C_BUILDFLAGS)

override CXX_BUILDFLAGS = $(eval \
  override CXX_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(cxxstd)) \
  $$(CXXFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CXXWARNFLAGS)))$(CXX_BUILDFLAGS)

override cc_id = $(eval override cc_id := $$(strip $$(if $$(cc__clang_major__),\
  clang $$(cc__clang_major__).$$(cc__clang_minor__).$$(cc__clang_patchlevel__),\
  gcc $$(cc__GNUC__).$$(cc__GNUC_MINOR__).$$(cc__GNUC_PATCHLEVEL__))))$(cc_id)

override cxx_id = $(eval override cxx_id := $$(strip $$(if $$(cxx__clang_major__),\
  clang++ $$(cxx__clang_major__).$$(cxx__clang_minor__).$$(cxx__clang_patchlevel__),\
  g++ $$(cxx__GNUC__).$$(cxx__GNUC_MINOR__).$$(cxx__GNUC_PATCHLEVEL__))))$(cxx_id)

endif
