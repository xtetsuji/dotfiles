# -*- mode: shell-script ; coding: utf-8 ; -*-

### relax if it is not interactive.
### (インタラクティブでない場合、何もしない)
test -z "$PS1" && return

UNAME="$(uname)"
BREW_PREFIX="$(brew --prefix)"

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

###
### Prompt
###
SCREEN_VERSION=$(screen -version | sed -e 's/^Screen version //' -e 's/ .*//')
case $UNAME in
    Darwin)
        PROMPT_ICON='\360\237\222\273' # computer
        #PROMPT_ICON='' # apple
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
    xterm-color)     color_prompt=yes;;
    xterm-256color)  color_prompt=yes;;
    screen)          color_prompt=yes;; # Is modern screen OK!?
    screen-256color) color_prompt=yes;;
esac

if [ -z "$debian_chroot" -a -r /etc/debian_chroot ] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [ "$color_prompt" = yes ] ; then
    # git プロンプト
    http-get-source \
        https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
        ~/.config/cache/http-get-source/git-prompt.sh
    # ひとまず絵文字 ($PROMPT_ICON) は入れない
    #PS1='[%:\j @\A]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " [\[\033[32m\]%s\[\033[0m\]]")\$ '
    PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " [\[\033[32m\]%s\[\033[0m\]]")\$ '
    COLOR_PROMPT_PS1="$PS1"
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
shopt -u histappend
shopt -s checkwinsize
### add at 2012/07/01
# http://blog.withsin.net/2010/12/29/bash%E3%81%AEhistcontrol%E5%A4%89%E6%95%B0/
# ignoredups：連続した同一コマンドの履歴を1回に
# ignorespace：空白から始まるコマンドを履歴に残さない
# ignoreboth:上記の両方を設定
export HISTCONTROL=ignoreboth

###
### PROMPT_COMMAND
###
if [ "$PS1" ] ; then
    function prompt_command {
        share_history
    }
    function choice-prompt {
        local type="$1"
        case "$type" in
            default-color)
                PS1="$COLOR_PROMPT_PS1"
                ;;
            simple)
                PS1='$ '
                ;;
            *)
                echo Usage:
                echo "  $FUNCNAME: [default-color|simple]"
                ;;
        esac
    }
fi
if type prompt_command >/dev/null 2>&1 ; then
    PROMPT_COMMAND=prompt_command
fi

###
### bash_completion
###
for f in $BREW_PREFIX/etc/bash_completion /etc/bash_completion ; do
    test -f $f && source $f
done
unset f

# and see "~/.bash_completion". It is read by builtin bash_completion.

# bash_color
http-get-source \
    https://raw.githubusercontent.com/maxtsepkov/bash_colors/master/bash_colors.sh \
    ~/.config/cache/http-get-source/bash_colors

# git-completion
http-get-source \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    ~/.config/cache/http-get-source/git-completion.bash

# for my xssh command completion same as ssh.
shopt -u hostcomplete && complete -F _ssh xssh

###
### pager and editor
###
if type lv >/dev/null 2>&1 ; then
    export PAGER='lv -c'
elif type less >/dev/null 2>&1 ; then
    export PAGER='less -R'
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

unset UNAME
