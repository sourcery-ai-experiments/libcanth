override THIS_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

doc:
	@cd "$(THIS_DIR)" && doxygen Doxyfile

all: | doc

clean: override WHAT := $(THIS_DIR)html $(THIS_DIR)latex
clean:
	$(if $(wildcard $(WHAT)),$(RM) -r $(WHAT),@true)

.PHONY: all clean doc
