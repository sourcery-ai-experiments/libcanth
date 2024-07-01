override THIS_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

override TARGETS := test

    all:| $(TARGETS)
  clean:| $(TARGETS:%=clean-%)
install:| $(TARGETS:%=install-%)

override PUBLISH :=            \
      all $(TARGETS)           \
    clean $(TARGETS:%=clean-%) \
  install $(TARGETS:%=install-%)

.PHONY: $(PUBLISH)

# Prevent sub-target tab-completion and direct build.
ifneq (,$(filter $(PUBLISH),$(or $(MAKECMDGOALS),all)))

include $(THIS_DIR)../common.mk

$(call arg_var,CC,      gcc)
$(call arg_var,CXX,     g++)
$(call arg_var,CPU)
$(call arg_var,ARCH,    native)
$(call arg_var,TUNE,    native)
$(call arg_var,CFLAGS,  -O3 -march=$(ARCH) \
  -mtune=$(TUNE)$(if $(CPU), -mcpu=$(CPU)))
$(call arg_var,CXXFLAGS,-O3 -march=$(ARCH) \
  -mtune=$(TUNE)$(if $(CPU), -mcpu=$(CPU)))

override CFLAGS   := -std=gnu2x -Wall -Wextra -pedantic -pipe -flto=auto $(CFLAGS)
override CXXFLAGS := -std=gnu++23 -Wall -Wextra -pedantic -pipe -flto=auto $(CXXFLAGS)

override SRC_test := dstr.c test.c

$(call target_rules,$(TARGETS))

all clean install:; $(nop)

endif
