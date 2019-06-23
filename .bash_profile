# xtetsuji/dotfiles/.bash_profile
#
# write almost setting to ~/.bashrc
# see: https://qiita.com/dark-space/items/cf25001f89c41341a9fd

# ~/.bash_profile is personal profile for login shell.
# ~/.bashrc is personal "conversation" profile for subshell.
#
# ~/.bash_profile only offers environment varialble.
# and if possible, do not use external command to reduce cost.

umask 022

### read .bashrc and .bash_aliases (in .bashrc)
if [ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ] ; then
    source ~/.bashrc
fi

BASH_PROFILE_DONE=1