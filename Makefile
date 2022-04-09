# -*- makefile -*-

MANAGED_DOTFILES	= $(shell git ls-files '.??*' | grep -v '/' | sed -e 's|^|~/|')

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

# see: https://qiita.com/rtakasuke/items/85133e396ba766458c20
shellcheck:
	$(MAKE) shellcheck-bash_profile
	$(MAKE) shellcheck-bashrc

shellcheck-bash_profile:
	shellcheck .bash_profile --exclude=SC2148,SC1090

shellcheck-bashrc:
	shellcheck .bashrc --exclude=SC2148,SC1090


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
