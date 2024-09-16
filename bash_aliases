# -*- mode: shell-script ; coding: utf-8 ; -*-
# .bash_aliases - bash and zsh aliases
: "start .bash_aliases"

function push_path_var { test -d "$1" && PATH=$PATH:$1 ; }
function unshift_path_var { test -d "$1" && PATH=$1:$PATH ; }
function exists { type $1 >/dev/null 2>&1 ; }
function source_if_readable { test -r "$1" && source "$1" ; }
function is_current_bash { test -n "$BASH_VERSION" ; }
function is_current_zsh  { test -n "$ZSH_VERSION" ; }
function is_interactive_shell { [[ $- =~ i ]] ; }
if is_current_bash ; then
    function is_login_shell { shopt -q login_shell ; }
elif is_current_zsh ; then
    function is_login_shell { [[ -o login ]] ; }
fi
function is_darwin { test "${UNAME:=$(uname)}" = Darwin ; }
function is_linux  { test "${UNAME:=$(uname)}" = Linux  ; }
function is_cygwin { [[ "${UNAME:=$(uname)}" =~ ^CYGWIN ]] ; }
function is_codepsaces { test -n "$CODESPACES" && test "$CODESPACES" = true ; }
function is_kde { test -n "$KDE_FULL_SESSION" && test "$KDE_FULL_SESSION" = true ; }

# bkt - https://github.com/dimo414/bkt
# Cache commands using bkt if installed
#if command -v bkt >&/dev/null; then
if which bkt >/dev/null ; then
    bkt() { command bkt "$@"; }
else
    # If bkt isn't installed skip its arguments and just execute directly.
    # Optionally write a msg to stderr suggesting users install bkt.
    bkt() {
        while [[ "$1" == --* ]]; do shift; done
        "$@"
    }
fi

export BKT_TTL="120s"

###
### hooks
###
function __cdhook_screen_title_pwd {
    test "$TERM" = screen || return
    test "$CDHOOK_SCREEN_TITLE" = off && return
    local title gitdir="$(git rev-parse --show-superproject-working-tree --show-toplevel 2>/dev/null)"
    test -n "$gitdir" && title="git:${gitdir/*\//}" || title="${PWD/*\//}"
    test "$PWD" = "$HOME" && title="~"
    test "$PWD" = "/" && title="/"
    screen -X title "$title"
}


###
### Basics
###

if is_darwin ; then
    if exists gls ; then
        alias ls='gls --color=auto -F'
        # dircolors process is following
    else
        alias ls='ls -FG'
    fi

    alias ql='qlmanage -p 2>/dev/null'
    alias imgdim='sips -g pixelHeight -g pixelWidth $1'
    alias pbtee='cat | pbcopy ; sleep 1 ; pbpaste'
    alias pwdcopy='echo -n $(pwd)/ | pbcopy'
fi

if is_linux ; then
    alias ls='ls --color=auto -F'
    alias crontab='crontab -i'
fi

if is_kde ; then
    source_if_readable ~/.bash_aliases_kde
fi

if is_cygwin ; then
    alias ls='ls --color -F --show-control-chars'
    source_if_readable ~/.bash_aliases_cygwin
fi

if exists dircolors ; then
    if [ -f ~/.dir_colors ] ; then
        eval "$(dircolors -b ~/.dir_colors)"
    else
        eval "$(dircolors -b)"
    fi
fi

alias grep='grep --color=auto'
alias en='env LANG=C '
alias mv='mv -i'
alias tree='tree -NC' # tree -N for showing multibytes character
alias lv='lv -c'
alias less='less -R'

exists gtar      && alias tar=gtar
exists hub       && alias git=hub
exists colordiff && alias diff=colordiff
alias od='od -tx1z -Ax -v' # http://d.hatena.ne.jp/maji-KY/20110718/1310985449
exists highlight && alias hl=highlight # http://search.cpan.org/dist/App-highlight/
# http://suzuki.tdiary.net/20140516.html#p01
if [ -f /usr/local/bin/highlight ] ; then
    alias syntaxhi=/usr/local/bin/highlight
fi

###
### Perl
###
alias system-perldoc='/usr/bin/perldoc'
alias system-perl='/usr/bin/perl'
alias perl-deparse='perl -MO=Deparse '
alias perl-installed-modules="perl -MExtUtils::Installed -E 'say(\$_) for ExtUtils::Installed->new->modules'"
alias uri_unescape='perl -MURI::Escape=uri_unescape -E "say uri_unescape(join q/ /, @ARGV)" '
alias uri_escape='perl -MURI::Escape=uri_escape -E "say uri_escape(join q/ /, @ARGV)" '

ALIASES_DONE=1

: "end .bash_aliases"
