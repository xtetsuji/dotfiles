# -*- makefile -*-

BACKUP_EXT	= orig

usage:
	@echo "Usage:"
	@echo "  make list"
	@echo "  make deproy"

list:
	ls -a

deploy:
	@echo "Start deploy dotfiles current directory."
	@echo "If this is \"dotdir\", curretly it is ignored and copy your hand."
	for f in .??* ; do \
		test -d $${f} && continue ; \
		if [ -f ~/$${f} ] ; then \
			@echo "backup as $${f} to $${f}.$(BACKUP_EXT)" ; \
			@cp ~/$${f} ~/$${f}.$(BACKUP_EXT) ; \
		fi ; \
		ln -i -s $(PWD)/$${f} ~/ ; \
	done ; true
