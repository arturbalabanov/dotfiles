GIT_HOOKS_DIR := $(shell git config --global core.hooksPath)
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

.PHONY: install
install: install_binaries install_git_hooks

.PHONY: install_binaries
install_binaries:
	mkdir -p $(BINARIES_DIR)
	$(foreach bin,$(BINARIES),ln -sf $(shell realpath $(bin)) $(BINARIES_DIR)/; )
	chmod a+x $(BINARIES_DIR)/*


.PHONY: install_git_hooks
install_git_hooks:
ifeq ($(GIT_HOOKS_DIR),)
	$(warning "Skipping installing git hooks: 'git config --global core.hooksPath' is not set")
else
	mkdir -p $(GIT_HOOKS_DIR)
	ln -sf $(shell realpath git-hooks)/* $(GIT_HOOKS_DIR)/
	chmod a+x $(GIT_HOOKS_DIR)/*
endif
