# -*- makefile -*-

usage:
	@echo "Usage:"
	@echo "  make list"
	@echo "  make deproy"

list:
	ls -a

deploy:
	for f in .??* ; do \
		ln -i -s $(PWD)/$${f} ~/ ; \
	done ; true
