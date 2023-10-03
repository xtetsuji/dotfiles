# -*- shell-script -*-
: "start .zprofile"

umask 022

if [ -n "$ZSH_VERSION" ] && [ -f ~/.zshrc ] ; then
    source ~/.zshrc
fi

ZPROFILE_DONE=1

: "end .zprofile"
