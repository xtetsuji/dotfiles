# -*- shell-script -*-
: "start .zshrc"

UNAME="$(uname)"
#BREW_PREFIX="$(brew --prefix)"
BREW_PREFIX="/usr/local"

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
# if is_interactive_shell ; then
#     source_if_readable ~/.bash_completion
#     source_if_readable $BREW_PREFIX/etc/bash_completion
#     source_if_readable /etc/bash_completion
# fi
# TODO: completion

###
### Prompt
###
git_prompt_brew="/usr/local/etc/bash_completion.d/git-prompt.sh"
git_prompt_macos="/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
source "$git_prompt_macos"
if exists __git_ps1 ; then
    setopt PROMPT_SUBST
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b$(__git_ps1 " [\033[32m%s\033[0m]")%# '
else
    export PROMPT='%B%F{yellow}%n@%m%f:%F{blue}%0~%f%b%# '
fi
export RPROMPT='%D %T'

export MYSQL_PS1='\u@\h> '

###
### completion
###
autoload -U compinit
compinit

###
### hisotry and PROMPT_COMMAND
###

# TODO: history

###
### keybind
###

bindkey -s '^g' 'git '

###
### common env
###
source ~/.common_env

: "start .zshrc"
