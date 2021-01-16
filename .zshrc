# -*- shell-script -*-
: "start .zshrc"

UNAME="$(uname)"
#BREW_PREFIX="$(brew --prefix)"
BREW_PREFIX="/usr/local"

# autoload -U compinit promptinit
# compinit
# promptinit

# Emacs like keybind
bindkey -e

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
# if is_interactive_shell ; then
#     source_if_readable ~/.bash_completion
#     source_if_readable $BREW_PREFIX/etc/bash_completion
#     source_if_readable /etc/bash_completion
# fi
# TODO: completion

###
### Prompt
###
export PROMPT='[z]%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b%# '
#PROMPT='%F{bold blue}%t%f %F{yellow}%n@%m%f %F{green}%~%f$ '

git_prompt_brew="/usr/local/etc/bash_completion.d/git-prompt.sh"
git_prompt_macos="/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"

source "$git_prompt_macos"

if exists __git_ps1 ; then
    setopt PROMPT_SUBST
    # PS1='[%n@%m %c$(__git_ps1 " (%s)")]\$ '
    PROMPT='[z]%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b$(__git_ps1 " [\033[32m%s\033[0m]")%# '
fi

export MYSQL_PS1='\u@\h> '

###
### hisotry and PROMPT_COMMAND
###

# TODO: history

###
### keybind
###

bindkey -s '^g' 'git '

: "start .zshrc"
