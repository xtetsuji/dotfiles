# -*- makefile -*-

BACKUP_EXT	= orig
UNAME		= $(shell uname)

RSYNC_OPTS	= -avz -e ssh --exclude=Makefile --exclude=README.md --exclude=.git --exclude=.gitignore --exclude=.DS_Store

REMOTE_USER	= $(USER)
REMOTE_HOST	= 

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

deploy:
	@echo "Start deploy dotfiles current directory."
	@echo "If this is \"dotdir\", curretly it is ignored and copy your hand."
	for f in .??* ; do \
		test "$(IGNORE_EXIST_SYMLINK)" = 1 -a -L "$${f}" && continue ; \
		test "$${f}" = .git -o "$${f}" = .git/ && continue ; \
		test "$${f}" = .gitignore            && continue ; \
		test "$${f}" = .DS_Store             && continue ; \
		test "$${f}" = .xsession -a "$(UNAME)" = Darwin && continue ; \
		test -d "$${f}" && continue ; \
		if [ -f "~/$${f}" ] && [ ! -L "~/$${f}" ] ; then \
			echo ">>> backup as $${f} to $${f}.$(BACKUP_EXT)" ; \
			cp -v "~/$${f}" "~/$${f}.$(BACKUP_EXT)" ; \
		fi ; \
		ln -v -i -s "$(PWD)/$${f}" ~/ ; \
	done ; true

deploy-append:
	$(MAKE) deploy IGNORE_EXIST_SYMLINK=1

delete-symlink:
	cd ~ ; for f in .??* ; do \
		if [ -L "$${f}" ] ; then \
			ls -l $${f} ; \
			rm -i -v $${f} ; \
		fi ; done

upload-files: .dotfiles
	@echo "Start upload files to remote server."
	@echo "If this is \"dotdir\", currently it is ignored and copy your hand.";
	if [ -z "$(REMOTE_HOST)" ] ; then \
		echo "REMOTE_HOST is required" ; \
		exit 1 ; \
	fi
	rsync $(RSYNC_OPTS) ./ $(REMOTE_USER)@$(REMOTE_HOST):

dry-upload-files:
	$(MAKE) upload-files RSYNC_OPTS="--dry-run $(RSYNC_OPTS)"

.dotfiles:
	date +"%Y/%m/%d %H:%M:%S" > $@
	echo $(REMOTE_HOST) >> $@

update:
	git fetch
	git pull origin master

clean:
	rm -f .dotfiles
