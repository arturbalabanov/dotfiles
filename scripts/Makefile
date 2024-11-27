BINARIES_DIR := $(HOME)/.local/bin

# in the order of the greps:
# * ignore directories
# * ignore hidden files
# * ignore files with extensions
# * ignore this file (Makefile)

BINARIES := $(shell find . -type f \
			| grep -Ev '^\./.*/' \
			| grep -Ev '^\./\..*' \
			| grep -Ev '\.\w+' \
			| grep -Ev '^\./Makefile')

.PHONY: info
info:
	@echo "the following scripts will be installed in $(BINARIES_DIR):"
	@$(foreach bin,$(BINARIES),echo "    $(bin)"; )

.PHONY: install
install:
	mkdir -p $(BINARIES_DIR)
	$(foreach bin,$(BINARIES),ln -sf $(shell realpath $(bin)) $(BINARIES_DIR)/; )
	chmod a+x $(BINARIES_DIR)/*
