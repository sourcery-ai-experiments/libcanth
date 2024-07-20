ifneq (,$(strip $(THIS_DIR)))
ifndef __libcanth_common_mk_included__
override __libcanth_common_mk_included__ := 1

include $(lastword $(MAKEFILE_LIST:common.mk=mk/cc.mk))

$(call two-info,.about)
$(eval yeet:; $$(call msg,YEET,$$(Y__))@:)
.PHONY: yeet

endif
endif
