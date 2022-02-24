# -*- makefile -*-

MANAGED_DOTFILES	= $(shell git ls-files '.??*' | grep -v '/' | sed -e 's|^|~/|')
ALL_DOTFILES	= $(shell for f in .??* ; do echo "$$f" ; done | sed -e 's|^|~/|')

usage:
	@echo "Usage:"
	@echo "  make status"
	@echo "  make ~/.SOMEFILE"
	@echo "  make install-symlink"
	@echo "  make uninstall-symlink"

status:
	ls -l --color $(MANAGED_DOTFILES)

$(ALL_DOTFILES):
	@f=$$(basename $@) ; test -f "$$f" -a -f "$(CURDIR)/$$f"
	f=$$(basename $@) ; \
		ln -s "$(CURDIR)/$$f" "$@"

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
