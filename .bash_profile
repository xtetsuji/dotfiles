# xtetsuji/dotfiles/.bash_profile
#
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

### PATH of fundamental
export PATH
for d in ~/bin ~/Dropbox/bin ~/git/@github/xtetsuji/various-commands/bin ; do
    if [ -d $d ] ; then
        PATH=$PATH:$d
    fi
done
unset d
# TODO: each other two directries are same if one is symbolic link of another.

###
### xtenv
###
XTENV_CACHE_DIR=~/.config/xtenv/cache
if [ ! -d $XTENV_CACHE_DIR ] ; then
    mkdir -p $XTENV_CACHE_DIR
fi

###
### chdrip on xtenv
###
if type drip 2>&1 >/dev/null ; then
    xtenv-cache-eval "drip drip-init" "drip.init"
fi

###
### plenv on xtenv
###
if [ -d $HOME/.plenv ] ; then
    export PLENV_ROOT=$HOME/.plenv
    export PATH=$PLENV_ROOT/bin:$PATH
    #eval "$(plenv init -)"
    xtenv-cache-eval "plenv init -" "plenv.init"
    test -d $PLENV_ROOT || mkdir $PLENV_ROOT
fi

###
### rbenv on xtenv
###
if [ -d $HOME/.rbenv ] ; then
    export RBENV_ROOT=$HOME/.rbenv
    export PATH=$RBENV_ROOT/bin:$PATH
    xtenv-cache-eval "rbenv init -" "rbenv.init"
    test -d $RBENV_ROOT || mkdir $RBENV_ROOT
fi

###
### golang
###
# brew install go
if type go >/dev/null 2>&1 ; then
    #GO_VERSION=$(go version | sed -e 's/.*version go//' -e 's/ .*//')
    # go version コマンド実行が結構コストかかるので暫定的に固定
    GO_VERSION=1.8
    if ! [[ $GO_VERSION =~ ^[0-9][0-9.]+$ ]] ; then
        GO_VERSION=default
    fi
    if [ -d "$HOME/.go" ] ; then
        export GOPATH=$HOME/.go/$GO_VERSION
        export PATH=$GOPATH/bin:$PATH
        if [ ! -d $GOPATH ] ; then
            mkdir -p $GOPATH
        fi
    fi
fi

###
### Some PATHes
###
export MANPATH
export INFOPATH

###
### ssh-agent
###
# http://www.gcd.org/blog/2006/09/100/
MY_SSH_AUTH_SOCK_PATH="/tmp/ssh-agent-$USER"
if [ -S "$SSH_AUTH_SOCK" ]; then
    case $SSH_AUTH_SOCK in
    /tmp/*/agent.[0-9]*)
        ln -snf "$SSH_AUTH_SOCK" $MY_SSH_AUTH_SOCK_PATH \
                && export SSH_AUTH_SOCK=$MY_SSH_AUTH_SOCK_PATH
    esac
elif [ -S $MY_SSH_AUTH_SOCK_PATH ]; then
    export SSH_AUTH_SOCK=$MY_SSH_AUTH_SOCK_PATH
else
    : #echo "no ssh-agent"
fi

###
### Locale / Lang
###
export LANG=ja_JP.UTF-8
export LV="-Ou"
export TZ=JST-9

###
### Information
###
export icloud_drive=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs

BASH_PROFILE_DONE=1