# TODO: replace this with the new ansible playbooks
#       also requires changes to the yadm_pull and yadm_update scripts

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

PYTHON_SCRIPTS := $(shell find . -type f -name '*.py')

.PHONY: info
info:
	@echo "the following scripts will be installed in $(BINARIES_DIR):"
	@$(foreach bin,$(BINARIES),echo "    $(bin)"; )

.PHONY: install
install:
	mkdir -p $(BINARIES_DIR)
	$(foreach bin,$(BINARIES),ln -sf $(shell realpath $(bin)) $(BINARIES_DIR)/; )
	$(foreach script,$(PYTHON_SCRIPTS),echo '#!/usr/bin/env bash\nuv run --no-project "$(shell realpath $(script))" $$@' > $(BINARIES_DIR)/$(shell basename $(script) .py); )
	chmod a+x $(BINARIES_DIR)/*
