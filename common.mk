ifneq (,$(strip $(THIS_DIR)))
ifndef __libcanth_common_mk_included__
override __libcanth_common_mk_included__ := 1

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

override if-macro = $(if $(strip $(shell   \
  printf '#ifdef $(strip $1)\n1\n#endif\n' \
  | $(CC) $(CFLAGS) -E -P -xc -)),$2,$3)

$(call arg_var,O,$(THIS_DIR))
override O := $(O:/=)/

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
  override nop := @true
endif

ifeq (,$Q$V)
  override Y_ := (╯°□°）╯︵ ┻━┻
  override Y__ = $(call SGR,38;5;119,    $(Y_))
  override SGR = $(shell printf '\e[$1m%s\e[m' '$2')
  override msg = $(info $($1_pfx)$2)

  CLEAN_pfx   = $(eval CLEAN_pfx   := $$(call SGR,0;35,CLEAN   ))$(CLEAN_pfx)
  COMPILE_pfx = $(eval COMPILE_pfx := $$(call SGR,0;36,COMPILE ))$(COMPILE_pfx)
  INSTALL_pfx = $(eval INSTALL_pfx := $$(call SGR,1;36,INSTALL ))$(INSTALL_pfx)
  LINK_pfx    = $(eval LINK_pfx    := $$(call SGR,1;34,LINK    ))$(LINK_pfx)
  STRIP_pfx   = $(eval STRIP_pfx   := $$(call SGR,0;33,STRIP   ))$(STRIP_pfx)
  SYMLINK_pfx = $(eval SYMLINK_pfx := $$(call SGR,0;32,SYMLINK ))$(SYMLINK_pfx)
  YEET_pfx    = $(eval YEET_pfx    := $$(call SGR,38;5;191,YEET))$(YEET_pfx)
else
  override undefine Y__
  override undefine msg
endif

ifndef V
  override Q := @
endif

$(eval yeet:; $$(call msg,YEET,$$(Y__))@true)
.PHONY: yeet

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
endif
