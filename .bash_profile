# $Id$
# $Source$
#
# ~/.bash_profile is personal profile for login shell.
# ~/.bashrc is personal "conversation" profile for subshell.

umask 022

### read bashrc
if [ -n "$BASH_VERSION" ] ; then
    if [ -f ~/.bashrc ] ; then
        . ~/.bashrc
    fi
fi

### PATH
export PATH
if [ -d ~/bin ] ; then
    PATH=$PATH:~/bin
fi
if [ -d /opt/local/bin ] ; then
    # for MacPorts
    PATH=$PATH:/opt/local/bin
fi
if [ -d /Developer/usr/bin ] ; then
    # for Xcode3 on Lion
    PATH=$PATH:/Developer/usr/bin
fi
if [ -d ~/git/@github/xtetsuji/various-commands/bin ] ; then
    PATH=$PATH::~/git/@github/xtetsuji/various-commands/bin
fi

### Locale / Lang

# locale is UTF-8 ordinary on modern Debian and some dists.
if    [ -f /etc/locale.gen ] \
   && grep -i '^ja_JP\.UTF-8' /etc/locale.gen >/dev/null 2>&1 ; then
    export LANG=ja_JP.UTF-8
elif  [ -f /etc/locale.gen ] \
   && grep -i '^ja_JP\.eucJP' /etc/locale.gen >/dev/null 2>&1 ; then
    export LANG=ja_JP.eucJP
    export JLESSCHARSET=japanese-euc
else
    export LANG=C
fi

export TZ=JST-9

BASH_PROFILE_DONE=1
