# -*- makefile -*-

DOTFILES	= $(shell git ls-files '.??*' | grep -v '/' | sed -e 's|^|~/|')

usage:
	@echo "Usage:"
	@echo "  make list             #=> ls -a"
	@echo "  make deploy           #=> create symlink"
	@echo "  make deploy-append    #=> create symlink if not exist"
	@echo "  make delete-symlink   #=> delete symlink"
	@echo "  make upload-files     #=> rsync to REMOTE_USER@REMOTE_HOST"
	@echo "  make dry-upload-files #=> dry-run and ditto"
	@echo "  make update           #=> git pull origin master"

status:
	for target in $(DOTFILES) ; do \
		if [ -z "$$(stat -f '%T' $$target )" ] ; then \
			echo "- $$target" ; \
		else \
			stat -f '%T %N' $$target ; \
		fi ; \
	done

$(DOTFILES):
	@f=$$(basename $@) ; test -f "$$f" -a -f "$(CURDIR)/$$f"
	f=$$(basename $@) ; \
		ln -s "$(CURDIR)/$$f" "$@"

install-symlink:
	for target in $(DOTFILES) ; do \
		$(MAKE) $$target || exit 1 ; \
	done

uninstall-symlink:
	for target in $(DOTFILES) ; do \
		if [ -L $$target ] ; then \
			ls -l $$target ; \
			rm -v $$target ; \
		fi ; \
	done
