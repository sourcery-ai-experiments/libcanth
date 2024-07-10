ifndef __libcanth_internal_mk_included__
override __libcanth_internal_mk_included__ := 1

override define n:=


endef

override .      = $n
override .if    = $.\#if
override .elif  = $.\#elif
override .else  = $.\#else
override .ifdef = $.\#ifdef
override .endif = $.\#endif

override pfx-if = $(if $2,$1$2)
override sfx-if = $(if $1,$1$2)

# Read a command line variable with optional fallback.
override arg_var = $(call arg_var_,$(strip $(value 1)),$(strip $(value 2)))
override define arg_var_
  $(eval

    ifeq (,$$(filter file override undefined,$$(firstword $$(origin __default_$1))))
      # Unset the __default variable if it was set outside the makefile.
      override undefine __default_$1
    endif

    ifeq (environment,$$(firstword $$(origin $1)))
      # Unset the target variable if it originates from the environment.
      override undefine $1
    else ifeq (default,$$(origin $1))
      # The target variable is a make builtin default.
      ifdef 2
        # Explicit fallback takes precedence over a builtin default value.
        override undefine $1
      else ifneq (undefined,$$(origin __default_$1))
        # The __default variable takes precedence over the builtin default.
        override undefine $1
      endif
    endif

    ifeq (undefined,$$(origin $1))
      # The target variable is undefined, i.e. we can modify it.
      ifdef 2
        override $1 = $$(eval override $1 := $(value 2))$$($1)
      else ifneq (undefined,$$(origin __default_$1))
        override $1 = $$(eval override $1 := $$(value __default_$1))$$($1)
      endif
    endif
  )
endef

# Read a dependency config variable, fall back to pkg-config.
override pkg_libs   = $(call pkg_var,$2,$3,--libs,$1)
override pkg_cflags = $(call pkg_var,$2,$3,--cflags,$1)
override pkg_var    = \
  $(call pkg_var_,$(strip $1),$(strip $2),$(strip $3),$(strip $4))
override define pkg_var_
  $(eval
    ifdef $1
      ifeq (,$$(strip $$($1)))
        override undefine $1
      else ifeq (,$$(filter command,$$(firstword $$(origin $1))))
        override undefine $1
      else
        override __$1$1__ := $$($1)
        override $1 := $$(__$1$1__)
        override undefine __$1$1__
      endif
    endif
    ifndef $1
      $(and $3,$4,override $1 = $$(eval \
        override $1 := $$$$(or $$$$(shell $(PKG_CONFIG) $3 $4),$2))$$($1))
      ifndef $1
        $(if $2,override $1 := $2)
      endif
    endif)
endef

# $1: path of header file to import as make variables
# $2: preprocessor command, defaults to '$(CC) -E -xc'
override dbg-macro-header = $(info $(call .get-macro-header,$(value 1),$(value 2)))

# $1: path of header file to import as make variables
# $2: preprocessor command, defaults to '$(CC) -E -xc'
override get-macro-header = $(eval $(call .get-macro-header,$(value 1),$(value 2)))

# $1: path of header file to import as make variables
# $2: preprocessor command, defaults to '$(CC) -E -xc'
override .get-macro-header = $(subst #,$n,$(shell $(or $2,$(CC) -E -xc) -w -P $1 |\
  sed 's/^  *//;s/  *$$//;/^$$/d;s/^override/#override/' | tail -c+2 | tr -d '\n'))

# $1: path of header file to create
# $2: list of preprocessor macro names to export as make variables
# $3: optional content to place above the generated export directives
override gen-guarded-macro-header = $(call .gen-macro-header \
  ,$(value 1),$(value 2),$(value 3),$(strip libcanth_$(shell \
  echo '$(abspath $(strip $1))' | sha256sum | cut -c1-64)_))

# $1: path of header file to create
# $2: list of preprocessor macro names to export as make variables
# $3: optional content to place above the generated export directives
override gen-macro-header = $(call .gen-macro-header,$(value 1),$(value 2),$(value 3))

# $1: path of header file to create
# $2: list of preprocessor macro names to export as make variables
# $3: optional content to place above the generated export directives
# $4: optional header guard macro name
override .gen-macro-header = $(file >$1,$(if $(strip $4),#ifndef $4$n#define $4)$(if $(strip\
 $(value 3)),$(value 3))$(foreach m,$2,$(call gen-macro-export,$m))$(if $(strip $4),$n#endif // $4))

override gen-macro-export = $n\#ifdef $1$n\#pragma push_macro("$1")$n\#undef $1$n\#define\
 $1 override $1:=_Pragma("pop_macro(\"$1\")")$1$n$1$n\#else$noverride undefine $1$n\#endif

override define import-macros
$(foreach v,$2 $3,$(eval override $v = $$(.get-$O$(strip $1).h)$$($v)))
$(eval override .ext-$O$(strip $1).h := $$(value 4))
$(eval override .get-$O$(strip $1).h = $$(eval \
  $$(call gen-macro-header,$O$(strip $1).h,$2,$$(value .ext-$O$(strip $1).h)) \
  $$(call get-macro-header,$O$(strip $1).h)override undefine .get-$O$(strip $1).h))
endef

# Generate rules and dependencies.
override define target_rules
$(eval override undefine OBJ)
$(foreach t,$1,$(eval $t:| $$O$t)                                       \
  $(eval override OBJ_$t     := $$(SRC_$t:%=$$O%.o))                    \
  $(eval override DEP_$t     := $$(OBJ_$t:%.o=%.d))                     \
  $(eval override CC_OBJ_$t  := $$(OBJ_$t:%.cpp.o=))                    \
  $(eval override CXX_OBJ_$t := $$(OBJ_$t:%.c.o=))                      \
  $(eval $$(foreach s,$$(SRC_$t),                                       \
    $$(eval $$O$$s.o: $$(THIS_DIR)$$s)))                                \
  $(if $(CXX_OBJ_$t),                                                   \
    $(eval $$O$t: $$(OBJ_$t); $$(call msg,LINK,$$@)                     \
      +$Q$$(CXX) $$(CXX_BUILDFLAGS) -o $$@ $$^ $$(LIBS_$t))             \
    $(eval $$(CXX_OBJ_$t):; $$(call msg,COMPILE,$$@)                    \
      +$Q$$(CXX) $$(CXX_BUILDFLAGS) -o $$@ -c -MMD $$<),                \
    $(eval $$O$t: $$(OBJ_$t); $$(call msg,LINK,$$@)                     \
      +$Q$$(CC) $$(C_BUILDFLAGS) -o $$@ $$^ $$(LIBS_$t)))               \
  $(if $(CC_OBJ_$t),                                                    \
    $(eval $$(CC_OBJ_$t):; $$(call msg,COMPILE,$$@)                     \
      +$Q$$(CC) $$(C_BUILDFLAGS) -o $$@ -c -MMD $$<))                   \
  $(eval clean-$t: $$(eval override WHAT_$t :=                          \
    $$$$(wildcard $$O$t $$(OBJ_$t) $$(DEP_$t))))                        \
  $(eval clean-$t: $$(if $$(WHAT_$t),| yeet);$$(if $$(WHAT_$t),         \
    $$(call msg,CLEAN,$t)$Q$$(RM) $$(WHAT_$t),$(nop)))                  \
  $(eval install-$t:; $$(call msg,INSTALL,$t)$(nop))                    \
  $(eval override OBJ += $$(OBJ_$t))                                    \
)
$(eval override OBJ := $$(sort $$(OBJ)) \
  $noverride DEP := $$(OBJ:%.o=%.d)     \
  $n-include $$(DEP)                    \
)
endef

endif
