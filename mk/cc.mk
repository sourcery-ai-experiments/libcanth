ifndef __libcanth_cc_mk_included__
override __libcanth_cc_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:cc.mk=arg.mk))

override __default_CPPFLAGS  = $(if $(DEBUG),,-DNDEBUG)
override __default_WARNFLAGS = -Wall -Wextra -Wpedantic

$(call arg_var,ARCH,native)
$(call arg_var,CC,gcc)
$(call arg_var,CPPFLAGS)
$(call arg_var,CPU)
$(call arg_var,CXX,g++)
$(call arg_var,TUNE,native)
$(call arg_var,WARNFLAGS)

$(call arg_bool_var,NO_COLOR)
$(call arg_bool_var,USE_CLANG)

$(call import-macros,                   \
  cc, $(CC) -E -xc,                     \
  __GNUC__                              \
  __GNUC_MINOR__                        \
  __GNUC_PATCHLEVEL__                   \
  __clang_major__                       \
  __clang_minor__                       \
  __clang_patchlevel__,                 \
  __default_CSTD,                       \
  $(.ifdef) __clang_major__             \
    $(.if) __clang_major__ > 17         \
      $.override __default_CSTD:=gnu23  \
    $(.elif) __clang_major__ > 8        \
      $.override __default_CSTD:=gnu2x  \
    $(.endif)                           \
  $(.elif) __GNUC__ > 13                \
    $.override __default_CSTD:=gnu23    \
  $(.elif) __GNUC__ > 8                 \
    $.override __default_CSTD:=gnu2x    \
  $(.endif))
$(call arg_var,CSTD)

override __default_USE_CCLANG = $(or $(USE_CLANG),$(if $(cc__clang_major__),1))
$(call arg_bool_var,USE_CCLANG)
$(if $(DEBUG_MK),$(info USE_CCLANG="$(USE_CCLANG)"))

override __default_CWARNFLAGS   = \
  $(if $(USE_CCLANG),             \
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
  __default_CXXSTD,                        \
  $(.ifdef) __clang_major__                \
    $(.if) __clang_major__ > 16            \
      $.override __default_CXXSTD:=gnu++23 \
    $(.elif) __clang_major__ > 11          \
      $.override __default_CXXSTD:=gnu++2b \
    $(.elif) __clang_major__ > 9           \
      $.override __default_CXXSTD:=gnu++20 \
    $(.elif) __clang_major__ > 4           \
      $.override __default_CXXSTD:=gnu++2a \
    $(.endif)                              \
  $(.elif) __GNUC__ > 10                   \
    $.override __default_CXXSTD:=gnu++23   \
  $(.elif) __GNUC__ > 9                    \
    $.override __default_CXXSTD:=gnu++20   \
  $(.elif) __GNUC__ > 7                    \
    $.override __default_CXXSTD:=gnu++2a   \
  $(.endif))
$(call arg_var,CXXSTD)

override __default_USE_CXXCLANG = $(or $(USE_CLANG),$(if $(cxx__clang_major__),1))
$(call arg_bool_var,USE_CXXCLANG)
$(if $(DEBUG_MK),$(info USE_CXXCLANG="$(USE_CXXCLANG)"))

override __default_CXXWARNFLAGS = \
  $(if $(USE_CXXCLANG),           \
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

override __default_NO_LTO = $(filter-out 11,$(USE_CCLANG)$(USE_CXXCLANG))
$(call arg_bool_var,NO_LTO)
$(if $(DEBUG_MK),$(info NO_LTO="$(NO_LTO)"))

override __default_CFLAGS = $(if $(ARCH),-march=$(ARCH)) $(if $(CPU),-mcpu=$(CPU)) \
  $(if $(TUNE),-mtune=$(TUNE)) -O$(if $(DEBUG),$(if $(USE_CCLANG),0,g) -ggdb3,2)   \
  $(if $(NO_COLOR),,$(if $(USE_CCLANG),-fcolor-diagnostics))                       \
  $(if $(NO_LTO),,-flto=$(if $(USE_CCLANG),full,auto)) -pipe
$(call arg_var,CFLAGS)

override __default_CXXFLAGS = $(if $(ARCH),-march=$(ARCH)) $(if $(CPU),-mcpu=$(CPU)) \
  $(if $(TUNE),-mtune=$(TUNE)) -O$(if $(DEBUG),$(if $(USE_CXXCLANG),0,g) -ggdb3,2)   \
  $(if $(NO_COLOR),,$(if $(USE_CXXLANG),-fcolor-diagnostics))                        \
  $(if $(NO_LTO),,-flto=$(if $(USE_CXXLANG),full,auto)) -pipe
$(call arg_var,CXXFLAGS)

override C_BUILDFLAGS = $(eval \
  override C_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(CSTD)) \
  $$(CFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CWARNFLAGS)))$(C_BUILDFLAGS)

override CXX_BUILDFLAGS = $(eval \
  override CXX_BUILDFLAGS := $$(strip $$(call pfx-if,-std=,$$(CXXSTD)) \
  $$(CXXFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CXXWARNFLAGS)))$(CXX_BUILDFLAGS)

override cc_id = $(eval override cc_id := $$(strip $$(if $$(cc__clang_major__),\
  clang $$(cc__clang_major__).$$(cc__clang_minor__).$$(cc__clang_patchlevel__),\
  gcc $$(cc__GNUC__).$$(cc__GNUC_MINOR__).$$(cc__GNUC_PATCHLEVEL__))))$(cc_id)

override cxx_id = $(eval override cxx_id := $$(strip $$(if $$(cxx__clang_major__),\
  clang++ $$(cxx__clang_major__).$$(cxx__clang_minor__).$$(cxx__clang_patchlevel__),\
  g++ $$(cxx__GNUC__).$$(cxx__GNUC_MINOR__).$$(cxx__GNUC_PATCHLEVEL__))))$(cxx_id)

endif
