# -*- mode: shell-script ; coding: utf-8 ; -*-

### relax if it is not interactive.
### (インタラクティブでない場合、何もしない)
test -z "$PS1" && return

UNAME="$(uname)"

# コマンド入力や通知などのインタラクティブなもの

###
### read some config
###

### Personal secret settings.
if [ -f ~/.bash_secret ] ; then
    source ~/.bash_secret
fi
### Aliases
if [ -f ~/.bash_aliases ] ; then
    source ~/.bash_aliases
fi

# ### add at 2011/11/07
# if [ -n "$PERL_ENVIRONMENT_SETUP" ] && [ -f ~/perl5/perlbrew/etc/bashrc ] ; then
#     source ~/perl5/perlbrew/etc/bashrc
#     PERL_ENVIRONMENT_SETUP=1
# fi
#
# perlbrew / plenv setups move to .bash_profile (2015/05/31)

###
### Prompt
###
case $(uname) in
    Darwin)
        emoji_prompt=yes
        PROMPT_ICON='\360\237\222\273'
        ;;
    Linux)
        if  [ -f /etc/debian_versin ] ; then
            # うずまき
            PROMPT_ICON='\360\237\214\200'
        fi
        ;;
    *)
        emoji_prompt=no
        PROMPT_ICON=''
        ;;
esac

case "$TERM" in
    xterm-color) color_prompt=yes;;
    xterm-256color) color_prompt=yes;;
    screen) color_prompt=yes;; # Is modern screen OK!?
    screen-256color) color_prompt=yes;;
esac
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
if [ "$color_prompt" = yes ] ; then
    #PS1="${PROMPT_ICON} "'${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    # see: http://j-caw.co.jp/blog/?p=901
    # brew install bash-git-prompt (for Mac)
    # git プロンプト
    http-get-source https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh ~/.git-prompt.sh
    PS1="${PROMPT_ICON} "'(\j)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " [\[\033[32m\]%s\[\033[0m\]]")\$ '
fi
unset color_prompt

export MYSQL_PS1='\u@\h> '

###
### Growl
###

### add at 2013/02/24
if [ "$UNAME" = Darwin ] ; then
    export GROWL_ANY_DEFAULT_BACKEND=CocoaGrowl
    export GROWL_ANY_DEBUG=0
    # I like CocoaGrowl than MacGrowl.
fi

###
### proxy
###
# export http_proxy=http://localhost:8080/
# export https_proxy=$http_proxy
# export ftp_proxy=$http_proxy
# export HTTPS_PROXY=$http_proxy
# export FTP_PROXY=$http_proxy
### NOTE: proxy environments are detected chproxy function or on .bash_secret.

###
### history
###
# see: http://tukaikta.blog135.fc2.com/blog-entry-187.html
function share_history {
    history -a
    history -c
    history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
shopt -s checkwinsize
### add at 2012/07/01
# http://blog.withsin.net/2010/12/29/bash%E3%81%AEhistcontrol%E5%A4%89%E6%95%B0/
# ignoredups：連続した同一コマンドの履歴を1回に
# ignorespace：空白から始まるコマンドを履歴に残さない
# ignoreboth:上記の両方を設定
export HISTCONTROL=ignoreboth

###
### bash_completion
###
if type brew >/dev/null 2>&1 && [ -f $(brew --prefix)/etc/bash_completion ] ; then
    # Mac homebrew
    source $(brew --prefix)/etc/bash_completion
elif [ -f /etc/bash_completion ] ; then
    # Debian
    source /etc/bash_completion
fi
# and see "~/.bash_completion". It is read by builtin bash_completion.

# git の補完に必要
if [ ! -f ~/.git-completion.bash ] ; then
    echo "Download git-completion.bash to ~/"
    curl --silent https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-completion.bash
fi
source ~/.git-completion.bash

###
### pager and editor
###

### add at 2012/03/19
if type lv >/dev/null 2>&1 ; then
    export PAGER='lv -c'
elif type jless >/dev/null 2>&1 ; then
    export PAGER=jless
elif type less >/dev/null 2>&1 ; then
    export PAGER=less
else
    export PAGER=more
fi

if type vi >/dev/null 2>&1 ; then
    export EDITOR=vi
fi

if type less &>/dev/null ; then
    export LESS=-M
    if type /usr/bin/lesspipe &>/dev/null ; then
        export LESSOPEN="| /usr/bin/lesspipe '%s'"
        export LESSCLOSE="/usr/bin/lesspipe '%s' '%s'"
    fi
    case "$LANG" in
        ja_JP.UTF-8) JLESSCHARSET=utf-8 ;    LV=-Ou8 ;;
        ja_JP.*) JLESSCHARSET=japanese-euc ; LV=-Oej ;;
        *) JLESSCHARSET=latin1 ;             LV=-Al1 ;;
    esac
    export JLESSCHARSET LV
elif [ "$UNAME" =~ CYGWIN.* ] ; then # Do not quote "=~"'s right side.
    alias lv='lv -Os'
fi

###
### some settings
###

# see: http://d.hatena.ne.jp/hogem/20090411/1239451878
# Ignore C-s for terminal stop.
stty stop undef

###
### some config by env
###

export CVS_RSH=ssh
export RSYNC_RSH=ssh
export PERLDOC_PAGER='lv -c'

set bell-style visible

# avoid Ctrl-D logout.
IGNOREEOF=3

### add at 2012/04/25
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
export AWS_RDS_HOME=$HOME/tmp/RDSCli-1.6.001
export AWS_CREDENTIAL_FILE=$AWS_RDS_HOME/credential-file-path

unset UNAME

