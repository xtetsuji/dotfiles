# -*- mode: shell-script ; coding: utf-8 ; -*-

UNAME="$(uname)"
#BREW_PREFIX="$(brew --prefix)"
BREW_PREFIX="/usr/local"

function is_login_shell { shopt -q login_shell ; }
function is_interactive_shell { [[ $- =~ i ]] ; }
function exists { type $1 >/dev/null 2>&1 ; }
function source_if_readable { test -r "$1" && source "$1" ; }
function add_path_var { test -d $1 && PATH=$PATH:$1 ; }

source ~/.bash_aliases
source_if_readable ~/.bash_secret
if is_interactive_shell ; then
    source_if_readable ~/.bash_completion
    source_if_readable $BREW_PREFIX/etc/bash_completion
    source_if_readable /etc/bash_completion
fi
###
### Path
###
export PATH
add_path_var ~/bin
add_path_var ~/Dropbox/bin
add_path_var /usr/local/bin

###
### Prompt
###
case "$TERM" in
    *color*) color_prompt=yes;;
    screen) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ] ; then
    # git プロンプト
    http-get-source \
        https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
        ~/.config/cache/http-get-source/git-prompt.sh
    PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " [\[\033[32m\]%s\[\033[0m\]]")\$ '
    COLOR_PROMPT_PS1="$PS1"
fi
unset color_prompt

export MYSQL_PS1='\u@\h> '

###
### history and PROMPT_COMMAND
###
# see: http://tukaikta.blog135.fc2.com/blog-entry-187.html
function share_history {
    history -a
    history -c
    history -r
}
shopt -u histappend
shopt -s checkwinsize
### add at 2012/07/01
# http://blog.withsin.net/2010/12/29/bash%E3%81%AEhistcontrol%E5%A4%89%E6%95%B0/
# ignoredups：連続した同一コマンドの履歴を1回に
# ignorespace：空白から始まるコマンドを履歴に残さない
# ignoreboth:上記の両方を設定
export HISTCONTROL=ignoreboth

if is_interactive_shell ; then
    function prompt_command {
        share_history
    }
    PROMPT_COMMAND=prompt_command
fi

###
### pager and editor
###
export PAGER=less
export EDITOR=vi

# less
export LESS='-i -M -R -S '
export LESS_TERMCAP_mb=$'\E[01;31m'      # Begins blinking.
export LESS_TERMCAP_md=$'\E[01;31m'      # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'          # Ends mode.
export LESS_TERMCAP_se=$'\E[0m'          # Ends standout-mode.
export LESS_TERMCAP_so=$'\E[00;47;30m'   # Begins standout-mode.
export LESS_TERMCAP_ue=$'\E[0m'          # Ends underline.
export LESS_TERMCAP_us=$'\E[01;32m'      # Begins underline.
if type lesspipe.sh >/dev/null 2>&1 ; then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# git
export GIT_PAGER='less -FRX'

# perldoc
export PERLDOC_PAGER='less -FRX'

# lv
export LV='-c -Ouj'

# vim (if exist)
if exists vim ; then
    export EDITOR=vim
fi

###
### Locale / Lang
###
export LANG="ja_JP.UTF-8"
export LC_COLLATE="ja_JP.UTF-8"
export LC_CTYPE="UTF-8"
export LC_MESSAGES="ja_JP.UTF-8"
export LC_MONETARY="ja_JP.UTF-8"
export LC_NUMERIC="ja_JP.UTF-8"
export LC_TIME="ja_JP.UTF-8"
export LC_ALL=

export TZ=JST-9

export CVS_RSH=ssh
export RSYNC_RSH=ssh

###
### Information
###
export icloud_drive=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs

###
### some settings
###

# see: http://d.hatena.ne.jp/hogem/20090411/1239451878
# Ignore C-s for terminal stop.
stty stop undef

set bell-style visible

# avoid Ctrl-D logout.
IGNOREEOF=3

function import-clr {
    http-get-source \
        https://raw.githubusercontent.com/maxtsepkov/bash_colors/master/bash_colors.sh \
        ~/.config/cache/http-get-source/bash_colors
    echo "import clr_*"
    echo "  clr_dump:"
    clr_dump
}



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
fi

###
### rbenv on xtenv
###
if [ -d $HOME/.rbenv ] ; then
    export RBENV_ROOT=$HOME/.rbenv
    export PATH=$RBENV_ROOT/bin:$PATH
    xtenv-cache-eval "rbenv init -" "rbenv.init"
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

unset UNAME
