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

$(call arg_bool_var,color)
$(call arg_bool_var,no_color)
$(call arg_bool_var,save_temps)
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

override __default_CWARNFLAGS =         \
  $(if $(use_cclang),                   \
    -Weverything                        \
    $(addprefix -Wno-,                  \
      c++98-compat                      \
      c++98-compat-pedantic             \
      declaration-after-statement       \
      disabled-macro-expansion          \
      pre-c11-compat                    \
      pre-c23-compat                    \
      pre-c2x-compat                    \
      unknown-warning-option            \
      unsafe-buffer-usage               \
      $(if                              \
        $(filter 0 1 2 3 4 5 6          \
          7 8 9 10 11 12 13 14,         \
          $(c__clang_major__)           \
        ),,                             \
        gnu-line-marker                 \
      )                                 \
    )                                   \
    $(if $(c__apple_build_version__),   \
      -Wno-poison-system-directories))

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

override __default_CXXWARNFLAGS =       \
  $(if $(use_cxxclang),                 \
    -Weverything                        \
    $(addprefix -Wno-,                  \
      c++98-compat                      \
      c++98-compat-pedantic             \
      declaration-after-statement       \
      disabled-macro-expansion          \
      pre-c11-compat                    \
      pre-c23-compat                    \
      pre-c2x-compat                    \
      unknown-warning-option            \
      unsafe-buffer-usage               \
      $(if                              \
        $(filter 0 1 2 3 4 5 6          \
          7 8 9 10 11 12 13 14,         \
          $(cxx__clang_major__)         \
        ),,                             \
        gnu-line-marker                 \
      )                                 \
    )                                   \
    $(if $(cxx__apple_build_version__), \
      -Wno-poison-system-directories))

$(call arg_var,CXXWARNFLAGS)

override __default_no_lto = $(filter-out 11,$(use_cclang)$(use_cxxclang))
$(call arg_bool_var,no_lto)
$(if $(DEBUG_MK),$(info no_lto="$(no_lto)"))

override define get-buildflags
$(strip                                 \
  $(if $($1_std),-std=$($1_std))        \
  $(if $($1_arch),-march=$($1_arch))    \
  $(if $($1_cpu),-mcpu=$($1_cpu))       \
  $(if $($1_tune),-mtune=$($1_tune))    \
  $(if $(use_$1clang),                  \
    $(if $(debug),                      \
      -O0 -ggdb3,                       \
      -O2                               \
    )                                   \
    $(if $(no_lto),,-flto=full)         \
    $(if $(save_temps),-save-temps=obj) \
    -pipe                               \
    $(if $(no_color),                   \
      $(if $(color),,                   \
        -fno-color-diagnostics          \
      ),                                \
      $(if $(color),                    \
        -fcolor-diagnostics             \
      )                                 \
    ),                                  \
    $(if $(debug),                      \
      -Og                               \
      $(if $($1__APPLE__),              \
        -ggdb2,                         \
        -ggdb3                          \
      ),                                \
      -O2                               \
    )                                   \
    $(if $(no_lto),,-flto=auto)         \
    $(if $(save_temps),                 \
      -save-temps$(if $(filter          \
        0 1 2 3 4 5 6 7 8 9 10,         \
        $($1__GNUC__)),=obj),           \
      -pipe                             \
    )                                   \
    $(if $(no_color),                   \
      $(if $(color),,                   \
        -fno-diagnostics-color          \
      ),                                \
      $(if $(color),                    \
        -fdiagnostics-color             \
      )                                 \
    )                                   \
  )                                     \
)
endef

override __default_CFLAGS = $(call get-buildflags,c)
$(call arg_var,CFLAGS)

override __default_CXXFLAGS = $(call get-buildflags,cxx)
$(call arg_var,CXXFLAGS)

override C_BUILDFLAGS = $(eval override C_BUILDFLAGS := $$(strip \
  $$(CFLAGS) $$(CPPFLAGS) $$(if $$(c_no_va_opt),-DNO_VA_OPT=1) \
  $$(WARNFLAGS) $$(CWARNFLAGS)))$(C_BUILDFLAGS)

override CXX_BUILDFLAGS = $(eval override CXX_BUILDFLAGS := $$(strip \
  $$(CXXFLAGS) $$(CPPFLAGS) $$(WARNFLAGS) $$(CXXWARNFLAGS)))$(CXX_BUILDFLAGS)

override CC_id = $(eval override CC_id := $$(strip\
  $$(if $$(c__clang_major__),$$(if $$(c__apple_build_version__),apple)\
    clang $$(c__clang_major__).$$(c__clang_minor__).$$(c__clang_patchlevel__),\
    gcc $$(c__GNUC__).$$(c__GNUC_MINOR__).$$(c__GNUC_PATCHLEVEL__))))$(CC_id)

override CXX_id = $(eval override CXX_id := $$(strip\
  $$(if $$(cxx__clang_major__),$$(if $$(cxx__apple_build_version__),apple)\
    clang++ $$(cxx__clang_major__).$$(cxx__clang_minor__).$$(cxx__clang_patchlevel__),\
    g++ $$(cxx__GNUC__).$$(cxx__GNUC_MINOR__).$$(cxx__GNUC_PATCHLEVEL__))))$(CXX_id)

endif
