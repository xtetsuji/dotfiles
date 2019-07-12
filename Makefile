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

list:
	ls -a

$(DOTFILES):
	@f=$$(basename $@) ; test -f "$$f" -a -f "$(CURDIR)/$$f"
	f=$$(basename $@) ; \
		ln -s "$(CURDIR)/$$f" "$@"

all-symlinks:
	for target in $(DOTFILES) ; do \
		$(MAKE) $$target || exit 1 ; \
	done

status:
	for target in $(DOTFILES) ; do \
		stat -f '%T %N' $$target ; \
	done

delete-symlink:
	cd ~ ; for f in .??* ; do \
		if [ -L "$${f}" ] ; then \
			ls -l $${f} ; \
			rm -i -v $${f} ; \
		fi ; done
