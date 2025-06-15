# -*- mode: shell-script ; coding: utf-8 ; -*-
: "start .bashrc"

#BREW_PREFIX="$(brew --prefix)"
if [ -d "/opt/homebrew" ] ; then
    BREW_PREFIX="/opt/homebrew"
elif [ -d "/usr/local/Cellar" ] ; then
    BREW_PREFIX="/usr/local/Cellar"
elif type brew >/dev/null 2>&1 ; then
    BREW_PREFIX="$(brew --prefix)"
fi

###
### Config
###
source ~/.path_functions
source ~/.common_env
source ~/.bash_aliases
source_if_readable ~/.bash_secret

###
### functions
###
# NOTE: function_cd.bash is disabled to prioritize zoxide's cd command
# source_if_readable ~/.function_cd.bash
source_if_readable ~/.function_cdwt.shell

###
### Prompt
###
case "$TERM" in
    *color*) color_prompt=yes;;
    screen) color_prompt=yes;;
esac

git_prompt_brew="$BREW_PREFIX/etc/bash_completion.d/git-prompt.sh"
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
fi

if [ "$TERM" = screen ] ; then
    PS1=$PS1'$(__cdhook_screen_title_pwd)'
fi

unset f color_prompt git_prompt_brew git_prompt_macos

###
### completion
###
if is_interactive_shell && ! is_codespaces ; then
    source_if_readable ~/.bash_completion
    source_if_readable "$BREW_PREFIX/etc/bash_completion"
    source_if_readable /etc/bash_completion
fi

###
### history and PROMPT_COMMAND
###
# see: http://tukaikta.blog135.fc2.com/blog-entry-187.html
# see: http://iandeth.dyndns.org/mt/ian/archives/000651.html
function share_history {
    history -a  # .bash_historyに前回コマンドを1行追記
    history -c  # 端末ローカルの履歴を一旦消去
    history -r  # .bash_historyから履歴を読み込み直す
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

###
### local setting (if exists)
###

source_if_readable ~/.bashrc.local

: "end .bashrc"
