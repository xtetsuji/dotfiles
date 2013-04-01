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

BASH_PROFILE_DONE=1
