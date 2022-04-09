# -*- makefile -*-

MANAGED_DOTFILES	= $(shell git ls-files '.??*' | grep -v '/' | sed -e 's|^|~/|')
ALL_DOTFILES	= $(shell for f in .??* ; do echo "$$f" ; done | sed -e 's|^|~/|')

usage:
	@echo "Usage:"
	@echo "  make status"
	@echo "  make targets"
	@echo "  make ~/.SOMEFILE"
	@echo "  make install-symlink"
	@echo "  make uninstall-symlink"

status:
	ls -l --color $(MANAGED_DOTFILES)

targets:
	@echo "Usage:"
	@for f in $(MANAGED_DOTFILES) ; do \
		echo "  make $$f" ; \
	done

$(MANAGED_DOTFILES):
	f="$@" ; ln -s "$(CURDIR)/$$(basename $$f)" "$$f"

install-symlink:
	for target in $(MANAGED_DOTFILES) ; do \
		$(MAKE) $$target || exit 1 ; \
	done

uninstall-symlink:
	for target in $(MANAGED_DOTFILES) ; do \
		if [ -L $$target ] ; then \
			ls -l $$target ; \
			rm -v $$target ; \
		fi ; \
	done
