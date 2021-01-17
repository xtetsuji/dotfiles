# -*- mode: shell-script ; coding: utf-8 ; -*-
: "start .bashrc"

UNAME="$(uname)"
#BREW_PREFIX="$(brew --prefix)"
BREW_PREFIX="/usr/local"

function add_path_var { test -d $1 && PATH=$PATH:$1 ; }

###
### Path
###
export PATH
add_path_var ~/bin
add_path_var ~/Dropbox/bin
add_path_var /usr/local/bin

###
### Config
###
source ~/.bash_aliases
source_if_readable ~/.bash_secret
if is_interactive_shell ; then
    source_if_readable ~/.bash_completion
    source_if_readable $BREW_PREFIX/etc/bash_completion
    source_if_readable /etc/bash_completion
fi

###
### Prompt
###
case "$TERM" in
    *color*) color_prompt=yes;;
    screen) color_prompt=yes;;
esac

git_prompt_brew="/usr/local/etc/bash_completion.d/git-prompt.sh"
git_prompt_macos="/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
if [ "$color_prompt" = yes ] ; then
    for f in "$git_prompt_brew" "$git_prompt_macos" ; do
        if [ -f "$f" ] ; then
            source "$f"
            break
        fi
    done

    if exists __git_ps1 ; then
        PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " [\[\033[32m\]%s\[\033[0m\]]")\$ '
    else
        PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    fi
    COLOR_PROMPT_PS1="$PS1"
fi

unset f color_prompt git_prompt_brew git_prompt_macos

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
### keybind
###

bind '"\C-g": "git "'

unset UNAME

###
### common env
###
source ~/.common_env

: "end .bashrc"
