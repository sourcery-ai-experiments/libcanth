ifndef __libcanth_internal_mk_included__
override __libcanth_internal_mk_included__ := 1

# Read a command line variable with optional fallback.
override arg_var = $(call arg_var_,$(strip $1),$(strip $2))
override define arg_var_
  $(eval
    ifdef $1
      ifeq (,$$(strip $$($1)))
        override undefine $1
      else ifeq (,$$(filter command$(if $2,, default), \
                            $$(firstword $$(origin $1))))
        override undefine $1
      else
        override __$1$1__ := $$($1)
        override $1 := $$(__$1$1__)
        override undefine __$1$1__
      endif
    endif
    ifndef $1
      $(if $2,override $1 := $2)
    endif)
endef

override define nl


endef

override define get-defs
$(eval $(subst #,$(nl),$(shell \
  for m in $2; do \
    printf '#ifdef %s\n#pragma push_macro("%s")\n#undef %s\n#define %s override %s:=_Pragma("pop_macro(\\"%s\\")")%s\n%s\n#else\noverride undefine %s\n#endif\n' \
           "$$m" "$$m" "$$m" "$$m" "$$m" "$$m" "$$m" "$$m" "$$m"; \
  done | $1 -w -P - | sed -E 's/^ +//;s/([^ =]) *$$/\1#/' | tr -d '\n')))
endef

override define import-macros
$(eval override $1 := $(strip $2))
$(eval override $(strip $1).get = $$(call get-defs,$$(CC) -E -xc,$$($(strip $1))))
$(foreach v,$($(strip $1)),$(eval $v = $$($(strip $1).get)$$($v)))
endef

# Generate rules and dependencies.
override define target_rules
$(eval override undefine DEP)
$(foreach t,$1,$(eval $t:| $$O$t)                               \
  $(eval override OBJ_$t     := $$(SRC_$t:%=$$O%.o))            \
  $(eval override DEP_$t     := $$(OBJ_$t:%.o=%.d))             \
  $(eval override CC_OBJ_$t  := $$(OBJ_$t:%.cpp.o=))            \
  $(eval override CXX_OBJ_$t := $$(OBJ_$t:%.c.o=))              \
  $(eval $$(foreach s,$$(SRC_$t),                               \
    $$(eval $$O$$s.o: $$(THIS_DIR)$$s)))                        \
  $(if $(CXX_OBJ_$t),                                           \
    $(eval $$O$t: $$(OBJ_$t); $$(call msg,LINK,$$@)             \
      +$Q$$(CXX) $$(CXXFLAGS) -o $$@ $$^)                       \
    $(eval $$(CXX_OBJ_$t):; $$(call msg,COMPILE,$$@)            \
      +$Q$$(CXX) $$(CXXFLAGS) -o $$@ -c -MMD $$<),              \
    $(eval $$O$t: $$(OBJ_$t); $$(call msg,LINK,$$@)             \
      +$Q$$(CC) $$(CFLAGS) -o $$@ $$^))                         \
  $(if $(CC_OBJ_$t),                                            \
    $(eval $$(CC_OBJ_$t):; $$(call msg,COMPILE,$$@)             \
      +$Q$$(CC) $$(CFLAGS) -o $$@ -c -MMD $$<))                 \
  $(eval clean-$t: $$(eval override WHAT_$t :=                  \
    $$$$(wildcard $$O$t $$(OBJ_$t) $$(DEP_$t))))                \
  $(eval clean-$t: $$(if $$(WHAT_$t),| yeet);$$(if $$(WHAT_$t), \
    $$(call msg,CLEAN,$t)$Q$$(RM) $$(WHAT_$t),$(nop)))          \
  $(eval install-$t:; $$(call msg,INSTALL,$t)$(nop))            \
  $(eval override DEP += $$(DEP_$t))                            \
)
$(eval -include $$(DEP))
endef

endif
