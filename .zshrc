# -*- shell-script -*-
: "start .zshrc"

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
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b$(__git_ps1 " [\033[32m%s\033[0m]")%# '
else
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b%# '
fi
export RPROMPT='[%j%1(j.:$(jobs|perl -e "print join q(,), map { /^\[\d+\](?:  [+-])?\s+\w+\s+(\S+)/ } <>").)] %F{black}%1(?.%K{red}.%K{green})↪%?%k%f @%T'

export MYSQL_PS1='\u@\h> '

###
### completion
###
autoload -Uz compinit && compinit

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

: "end .zshrc"
