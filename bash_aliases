# -*- mode: shell-script ; coding: utf-8 ; -*-
# .bash_aliases - bash and zsh aliases
: "start .bash_aliases"

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

if is_cursor_local || is_cursor_codespaces ; then
    alias code='echo "dispatch cursor cli ✨" ; cursor'
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

exists hub       && alias git=hub
exists colordiff && alias diff=colordiff
alias od='od -tx1z -Ax -v' # http://d.hatena.ne.jp/maji-KY/20110718/1310985449
exists highlight && alias hl=highlight # http://search.cpan.org/dist/App-highlight/
# http://suzuki.tdiary.net/20140516.html#p01
if [ -f /usr/local/bin/highlight ] ; then
    alias syntaxhi=/usr/local/bin/highlight
fi

if exists eza ; then
    # The prefix 'e' in commands represents 'extended' or 'eza' (a modern ls replacement),
    # indicating enhanced functionality over standard commands.
    alias els='eza -F --color=auto --git '
    alias etree='eza -F --color=auto --git --tree '
fi

###
### JavaScript / TypeScript
###
# see: https://zenn.dev/mizchi/articles/experimental-node-typescript
# Simple version without arrays to avoid shell compatibility issues
alias nodets='node --experimental-strip-types --experimental-transform-types --experimental-detect-module --no-warnings=ExperimentalWarning'

###
### Perl
###
alias system-perldoc='/usr/bin/perldoc'
alias system-perl='/usr/bin/perl'
alias perl-deparse='perl -MO=Deparse '
alias perl-installed-modules="perl -MExtUtils::Installed -E 'say(\$_) for ExtUtils::Installed->new->modules'"
alias uri_unescape='perl -MURI::Escape=uri_unescape -E "say uri_unescape(join q/ /, @ARGV)" '
alias uri_escape='perl -MURI::Escape=uri_escape -E "say uri_escape(join q/ /, @ARGV)" '

###
### path
###
function pathctl {
    local subcommand="${1:-}"
    shift || true
    case "$subcommand" in
        view)
            echo "PATH=$PATH"
            ;;
        list)
            echo "$PATH" | tr : '\n'
            ;;
        uniq)
            PATH=$( perl -e 'print join ":", grep { !$seen{$_}++ } split /:/, $ENV{PATH}' )
            ;;
        exist)
            perl -e '$p = shift; exit($ENV{PATH} =~ /(?<=:|\A)\Q$p\E(?=:|\z)/ ? 0 : 1)' "$1"
            ;;
        *)
            echo "Usage: pathctl [view|list|uniq|exist]"
            ;;
    esac
}

ALIASES_DONE=1

: "end .bash_aliases"
