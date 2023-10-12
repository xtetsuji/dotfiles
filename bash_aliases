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
    if ! exists md5sum ; then
        if exists gmd5sum ; then
            alias md5sum=gmd5sum
        else
            alias md5sum='md5 -s '
        fi
    fi
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

###
### big functions
###

is_current_zsh && \
function cd {
    local arg="$1" dir subcommand
    if [ "${arg:0:1}" = ":" ] ; then
        subcommand="${arg#:}"
        shift || true
        case "$subcommand" in
            planter)
                dir="$(planter peco)"
                ;;
            repo)
                dir=$(cd-plugin-repo | peco --select-1 --query="${1:-}")
                ;;
            isearch)
                dir="$(mdfind 'kMDItemContentType == "public.folder"' | peco --select-1 )"
                ;;
            isearch-home)
                dir="$(mdfind -onlyin $HOME 'kMDItemContentType == "public.folder"' | peco --select-1 )"
                ;;
            *)
                echo "subcommand \"$subcommand\" is not found"
                return 1
                ;;
        esac
        if [ -z "$dir" ] ; then
            echo "select stop"
            return
        fi
    else
        dir="$arg"
    fi
    if [ -z "$dir" ] ; then
        builtin cd
    else
        builtin cd "$dir"
    fi
}

# previous cd at 2005/03/22 (original idea)
# enahnced cd at 2019/03/31 (following)
is_current_bash && \
function cd {
    #set -x
    local arg="$1" subcommand result rc
    if [ -z "$arg" ] ; then ### home directory
        # cd 連打で余計な $DIRSTACK を増やさない
        test "$PWD" = "$HOME" || pushd $HOME >/dev/null
        return
    elif [ "${arg:0:1}" = ":" ] ; then ### command mode
        # コロンコマンドは xtcd.sh にディスパッチする
        subcommand="${arg#:}" ; shift
        case "$subcommand" in
            history)
                result="$( dirs -v | xtcd.sh :history "$@" )"
                ;;
            clear)
                dirs -c ; return
                ;;
            help|subcommands)
                xtcd.sh :$subcommand "$@"
                return
                ;;
            up|down|drop|which|pwdsed|repo|stdin|mdfind|bookmark)
                if [ $subcommand = bookmark -a $# -gt 0 ] ; then
                    # $() 中だと $EDITOR が起動できないので冒頭で処理している
                    xtcd.sh :bookmark "$@"
                    return
                fi
                result="$( xtcd.sh :$subcommand "$@" )"
                rc=$?
                if [ $rc = 100 ] ; then
                    # 終了ステータス100の場合、受け取った出力を流して、ここの（呼び出し元）で穏当に終了する
                    echo "$result"
                    return 0
                elif [ $rc -gt 0 ] ; then
                    echo "xtcd.sh returns error code" >&2
                    return 1
                fi
                ;;
            *)
                echo "unknown command :$subcommand" >&2
                return 1
                ;;
        esac
        if [ "${result:0:1}" = "~" ] ; then
            result=$HOME${result#"~"}
        fi
        if [ -f "$result" ] ; then
            result="${result%/*}"
        fi
    else
        result="$arg"
    fi
    if [ -n "$result" ] ; then
        pushd "$result" >/dev/null
        if [ -n "$subcommand" -a "$subcommand" = drop ] ; then
            cd :drop
        fi
    fi
    #set +x
}

# chenv - change environment variable at 2019/04/07
# with chenv.pl
function chenv {
    case "$#" in
        1)
            chenv.pl $1
            ;;
        2)
            local shcode="export $1=\"$(chenv.pl $1 $2)\""
            echo "$shcode"
            eval "$shcode"
            ;;
        *)
            echo -e "Usage:\n  chenv ENV_NAME [KEY]"
            ;;
    esac
}

function pathctl {
    local pathctl_out=_pathctl.sh
    local subcommand=${1:-}
    if [ -z "$subcommand" ] ; then
        $pathctl_out help
        return
    fi
    shift
    case "$subcommand" in
        add|delete|clean)
            # 編集系
            local new_path=$( $pathctl_out edited-path-string-by-$subcommand "$@" )
            test $? = 0 || return 1
            test "$PATH" = "$new_path" && { echo "PATH is not modified" ; return ; }
            test -z "$new_path" && { echo "new path is empty. error." ; return 1 ; }
            export PATH=$new_path
            ;;
        view|grep|dump)
            $pathctl_out $subcommand "$@"
            ;;
        *)
            echo "$FUNCNAME: unknown subcommand ($subcommand)"
            return 1
            ;;
    esac
    return $?
}

function jobs2 {
    #local line=$(builtin jobs | peco)
    local line=$(jobs | peco)
    local choice
    if [ -z "$line" ] ; then
        return
    fi
    #trap 'kill -INT $jobspec' INT
    echo $line
    read -p "Choice [fg|bg|cont|stop|disown|kill|kill -*|SIG***|NUMBER|pbcopy]: " choice
    jobspec=$(<<<"$line" sed -e 's/^\[/%/' -e 's/\].*//')
    case $choice in
        fg|bg|disown|kill|"kill -*")
            $choice $jobspec
            ;;
        cont)
            kill -CONT $jobspec
            ;;
        stop)
            kill -STOP $jobspec
            ;;
        SIG*)
            local signal=$(<<<"$choice" sed -e 's/^SIG//')
            kill -$signal $jobspec
            ;;
        [0-9]*)
            kill -$choice $jobspec
            ;;
        pbcopy)
            <<<"$line" pbcopy
            ;;
        *)
            fg $jobspec
            ;;
    esac
}

function ps2 {
    local lines=$(ps "$@" | peco)
    local choice pid
    if [ -z "$lines" ] ; then
        return
    fi
    echo $lines
    pids=$(<<<"$lines" perl -ne 'push @pids, (grep { /^\d+$/ } split / /, $_)[0]; END { print join " ", @pids; }')
    if [ -z "$pids" ] ; then
        echo "PID read error"
        return 1
    fi
    echo "pids $pids"
    # MEMO: zsh compatible, read `-p` option is different as printing prompt.
    #read -p "Choice [kill|kill -*|SIG***|pbcopy]: " choice
    echo -n "Choice [kill|kill -*|SIG***|pbcopy]: "
    read choice
    case $choice in
        kill|"kill -*")
            $choice $pid
            ;;
        SIG*)
            local signal=$(<<<"$choice" sed -e 's/^SIG//')
            kill -$signal $pids
            ;;
        pbcopy)
            <<<"$lines" pbcopy
            ;;
        *)
            ;;
    esac
}

ALIASES_DONE=1

: "end .bash_aliases"
