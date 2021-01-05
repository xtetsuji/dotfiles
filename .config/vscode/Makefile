# -*- makefile -*-
# see: https://qiita.com/miiina016/items/018331b36ecf57ed8973
# TODO: support keybindings.json

EXTENSION_FILE		= extensions
VSCODE_SETTING_DIR	= "$(HOME)/Library/Application Support/Code/User"
NOW_DATE			= $(shell date+%Y%m%d_%H%M%S)

usage:
	@echo "Usage:"
	@echo "  make create-symlink"
	@echo "  make delete-symlink"
	@echo "  make recreate-symlink"
	@echo "  make import-extensions"
	@echo "  make export-extensions"
	@echo ""
	@echo "  you can \"create-symlink\" in both repositry working and real ~/.config/vscode"

export-extensions:
	code --list-extensions > extensions

import-extensions:
	cat $(EXTENSION_FILE) | while read extension ; do \
		code --install-extension $$extension ; \
	done

create-symlink:
	target=$(VSCODE_SETTING_DIR)/settings.json ; \
	if [ -f "$$target" ] ; then \
		mv -v "$$target" "$$target.backup`date +%Y%m%d_%H%M%S`" ; \
	fi ; \
	ln -v -s $(PWD)/settings.json "$$target"

delete-symlink:
	rm $(VSCODE_SETTING_DIR)/settings.json

recreate-symlink:
	$(MAKE) delete-symlink
	$(MAKE) create-symlink
