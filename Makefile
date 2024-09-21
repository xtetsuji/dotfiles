# -*- makefile -*-

DOT_EXCLUDE_FILES_RE	= ^README\.md\$$|^Makefile\$$|^rclone\.sh\$$|^testproc\.sh\$$
MANAGED_DOTFILES	= $(shell git ls-files '*' | grep -v '/' | grep -E -v "$(DOT_EXCLUDE_FILES_RE)" | sed -e 's|^|~/.|')

usage:
	@echo "Usage:"
	@echo "  make status"
	@echo "  make targets"
	@echo "  make print-dotfiles"
	@echo "  make shellcheck"
	@echo "    make shellcheck-bash_profile"
	@echo "    make shellcheck-bashrc"
	@echo "  make ~/.SOMEFILE"
	@echo "  make install-all-symlink"
	@echo "  make uninstall-all-symlink"
	@echo ""
	@echo "Dotfiles symlink creation targets:"
	@$(MAKE) targets SUBTARGET=true

status:
	ls -l --color $(MANAGED_DOTFILES)

targets:
	@if [ -z "$(SUBTARGET)" ] ; then echo "Usage:" ; fi
	@for f in $(MANAGED_DOTFILES) ; do \
		echo "  make $$f" ; \
	done

# see: https://qiita.com/rtakasuke/items/85133e396ba766458c20
shellcheck:
	$(MAKE) shellcheck-bash_profile
	$(MAKE) shellcheck-bashrc

shellcheck-bash_profile:
	shellcheck bash_profile --exclude=SC2148,SC1090

shellcheck-bashrc:
	shellcheck bashrc --exclude=SC2148,SC1090

$(MANAGED_DOTFILES):
	ln -s "$(CURDIR)/$$(basename "$@")" "$@"

print-dotfiles:
	@xargs -n 1 echo <<<"$(MANAGED_DOTFILES)"

install-all-symlink:
	for target in $(MANAGED_DOTFILES) ; do \
		$(MAKE) $$target || exit 1 ; \
	done

uninstall-all-symlink:
	for target in $(MANAGED_DOTFILES) ; do \
		if [ -L $$target ] ; then \
			ls -l $$target ; \
			rm -v $$target ; \
		fi ; \
	done
