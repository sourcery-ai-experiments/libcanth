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

override SRC_test := compiler.c compiler.cpp $(if $(debug),dbg.c )dstr.c test.c
override LIBS_test = $(CJSON_LIBS)

$(call pkg_libs,libcjson,CJSON_LIBS,-lcjson)
$(call target_rules,$(TARGETS))

all clean install:; $(nop)

endif
