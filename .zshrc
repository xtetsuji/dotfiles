# -*- shell-script -*-
: "start .zshrc"

#zmodload zsh/zprof && zprof

UNAME="$(uname)"
#BREW_PREFIX="$(brew --prefix)"
BREW_PREFIX="/usr/local"

function push_path_var { test -d "$1" && PATH=$PATH:$1 ; }
function unshift_path_var { test -d "$1" && PATH=$1:$PATH ; }
alias add_path_var=push_path_var

###
### Path
###
export PATH
# https://qiita.com/y_310/items/101ef023124072b9c73f
add_path_var ~/bin
add_path_var ~/Dropbox/bin
add_path_var /usr/local/bin
unshift_path_var /usr/local/opt/coreutils/libexec/gnubin
unshift_path_var /usr/local/opt/zip/bin
unshift_path_var /usr/local/opt/unzip/bin

# /usr/share/zsh/5.8 is macOS 11 (Big Sur) default zsh library path
fpath=(/usr/share/zsh/5.8/functions/ $fpath)

# before `autoload -U XXX`,
# you may need to change load path directory permission: 775 -> 755
#   chmod 755 /usr/local/share/zsh
#   chmod 755 /usr/local/share/zsh/site-functions
# see: https://qiita.com/ayihis@github/items/88f627b2566d6341a741

###
### Config
###
source ~/.bash_aliases
source_if_readable ~/.bash_secret

###
### Prompt
###
setopt PROMPT_SUBST
git_prompt_brew="/usr/local/etc/bash_completion.d/git-prompt.sh"
git_prompt_macos="/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
source "$git_prompt_macos"
if exists __git_ps1 ; then
    # `%%` is character `%` on __git_ps1.
    # zsh color sequence %F{name} and %f are
    # right measurable as line character count.
    # see: https://scrapbox.io/jiro4989/Zsh%E3%81%AE%E3%83%97%E3%83%AD%E3%83%B3%E3%83%97%E3%83%88%E3%81%8C%E5%A4%89%E3%81%AA%E4%BD%8D%E7%BD%AE%E3%81%AB%E6%94%B9%E8%A1%8C%E3%81%95%E3%82%8C%E3%82%8B%E5%95%8F%E9%A1%8C%E3%81%AE%E8%A7%A3%E6%B1%BA
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b$(__git_ps1 " [%%F{green}%s%%f]")%# '
else
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b%# '
fi
if [ "$TERM" = screen ] ; then
    PROMPT+='$(__cdhook_screen_title_pwd)'
fi

PROMPT="%F{black}%1(?.%K{red}.%K{green})↪%?%k%f @%T $PROMPT"

#export RPROMPT='[%j%1(j.:$(jobs|perl -e "print join q(,), map { /^\[\d+\](?:  [+-])?\s+\w+\s+(\S+)/ } <>").)] %F{black}%1(?.%K{red}.%K{green})↪%?%k%f @%T'

export MYSQL_PS1='\u@\h> '

###
### completion
###
autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

###
### history
###
export HISTSIZE=2000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_no_store
setopt EXTENDED_HISTORY

###
### keybind
###

# Emacs like keybind
bindkey -e

bindkey -s '^g' 'git '


###
### common env
###
source ~/.common_env

#zmodload zsh/zprof && zprof

: "end .zshrc"
