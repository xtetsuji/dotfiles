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
	for target in $(MANAGED_DOTFILES) ; do \
		if [ -z "$$(stat -f '%T' $$target )" ] ; then \
			echo "- $$target" ; \
		else \
			stat -f '%T %N' $$target ; \
		fi ; \
	done

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
