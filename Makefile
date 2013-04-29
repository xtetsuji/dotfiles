# -*- makefile -*-

BACKUP_EXT	= orig
UNAME		= $(shell uname)

usage:
	@echo "Usage:"
	@echo "  make list"
	@echo "  make deproy"
	@echo "  make update #=> git pull origin master"

list:
	ls -a

deploy:
	@echo "Start deploy dotfiles current directory."
	@echo "If this is \"dotdir\", curretly it is ignored and copy your hand."
	for f in .??* ; do \
		test $${f} == .git -o $${f} == .git/ && continue ; \
		test $${f} == .gitignore && continue ; \
		test $${f} == .DS_Store && continue ; \
		test $${f} == .xsession -a "$(UNAME)" == Darwin && continue ; \
		test -d $${f} && continue ; \
		if [ -f ~/$${f} ] && [ ! -L ~/$${f} ] ; then \
			echo "backup as $${f} to $${f}.$(BACKUP_EXT)" ; \
			cp ~/$${f} ~/$${f}.$(BACKUP_EXT) ; \
		fi ; \
		ln -i -s $(PWD)/$${f} ~/ ; \
	done ; true

update:
	git pull origin master

