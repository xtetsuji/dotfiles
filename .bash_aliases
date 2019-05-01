# -*- mode: shell-script ; coding: utf-8 ; -*-

declare ALIASES=$HOME/.bash_aliases
declare UNAME=$(uname)

# xtenv-cache-eval CMD CACHE_FILE_NAME
# CMD の出力結果を CACHE_FILE_NAME にキャッシュしつつ eval する
# すでに CACHE_FILE_NAME があれば CMD を実行しない
# TODO: キャシュ有効期限を設定する？
function xtenv-cache-eval {
    test $# = 2 || { echo "$FUNCNAME COMMANDS FILENAME" ; return 1 ; }
    local init_script_generate_command="$1"
    local cache_file_name="$2"
    local cache_file_path="$XTENV_CACHE_DIR/$cache_file_name"
    if [ ! -f "$cache_file_path" ] ; then
        $init_script_generate_command > $cache_file_path
    fi
    eval "$(< "$cache_file_path" )"
}

###
### Basics
###

function exists { type $1 >/dev/null 2>&1 ; return $? ; }

case "$UNAME" in
    Darwin) ### Mac OS X
        alias ls='ls -FG' # BSD type "ls"
        # see: http://ascii.jp/elem/000/000/594/594203/
        test -f /Applications/Emacs.app/Contents/MacOS/bin/emacsclient && \
        alias emacsclient="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
        # Recommend to create symlink /usr/sbin/airport as the airport.
        if [ ! -f /sbin/airport ] || [ ! -f /usr/sbin/airport ] ; then
            alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
        fi
        alias ql='qlmanage -p 2>/dev/null'
        alias imgdim='sips -g pixelHeight -g pixelWidth $1'
        # see various-commands/alt-md5sum more.
        if exists alt-md5sum && ! exists md5sum ; then
            alias md5sum=alt-md5
        elif exists md5 && ! exists md5sum ; then
            alias md5sum='md5 -s '
        fi
        alias pbtee='cat | pbcopy ; sleep 1 ; pbpaste'
        alias pwdcopy='echo -n $(pwd)/ | pbcopy'

        # see: http://deeeet.com/writing/2014/04/30/beer-on-terminal/
        function beers () { ruby -e 'C=`stty size`.scan(/\d+/)[1].to_i;S=ARGV.shift||"\xf0\x9f\x8d\xba";a={};puts "\033[2J";loop{a[rand(C)]=0;a.each{|x,o|;a[x]+=1;print "\033[#{o};#{x}H \033[#{a[x]};#{x}H#{S} \033[0;0H"};$stdout.flush;sleep 0.01}' ; }
        ;;
    Linux)
        alias ls='ls --color=auto'
        alias crontab='crontab -i'
        source ~/.bash_aliases_kde
        ;;
    CYGWIN*)
        alias ls='ls --color -F --show-control-chars'
        source ~/.bash_aliases_cygwin
        ;;
esac

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

# previous cd at 2005/03/22 (original idea)
# enahnced cd at 2019/03/31 (following)
function cd {
    #set -x
    local arg="$1" subcommand result
    if [ -z "$arg" ] ; then ### home directory
        # cd 連打で余計な $DIRSTACK を増やさない
        test "$PWD" = "$HOME" || pushd $HOME >/dev/null
    elif [ "${arg:0:1}" = ":" ] ; then ### command mode
        # コロンコマンドは xtcd.sh にディスパッチする
        subcommand="${arg#:}" ; shift
        case "$subcommand" in
            help)
                xtcd.sh :help "$@" ; return
                ;;
            history)
                result="$( dirs -v | xtcd.sh :history "$@" )"
                ;;
            clear)
                dirs -c ; return
                ;;
            up|down|drop|which|pwdsed|repo|stdin|mdfind|bookmark)
                if [ $subcommand = bookmark -a $# -gt 0 ] ; then
                    xtcd.sh :bookmark "$@"
                    return
                fi
                result="$( xtcd.sh :$subcommand "$@" )"
                if [ $? -gt 0 ] ; then
                    echo "xtcd.sh returns error code" >&2
                    return 1
                fi
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
    read -p "Choice [kill|kill -*|SIG***|pbcopy]: " choice
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

# see: http://qiita.com/yungsang/items/09890a06d204bf398eea
#export HISTCONTROL="ignoredups"
# peco-history / C-x C-r
function peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi

    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}
bind '"\C-x\C-r":"peco-history\n"'

function http-get-source {
    local url=$1
    local file=$2
    if [ -n "$HTTP_GET_SOURCE_FORCE" ] || [ ! -f $file ] ; then
        curl --silent $url > $file
    fi
    if [ -s $file ] ; then
        source $file
    elif [ -f $file ] ; then
        echo "$FUNCNAME: $file is empty" >&2
    fi
}

unset ALIASES
unset UNAME

ALIASES_DONE=1
