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
        # see: http://deeeet.com/writing/2014/04/30/beer-on-terminal/
        function beers () { ruby -e 'C=`stty size`.scan(/\d+/)[1].to_i;S=ARGV.shift||"\xf0\x9f\x8d\xba";a={};puts "\033[2J";loop{a[rand(C)]=0;a.each{|x,o|;a[x]+=1;print "\033[#{o};#{x}H \033[#{a[x]};#{x}H#{S} \033[0;0H"};$stdout.flush;sleep 0.01}' ; }
        ;;
    Linux)
        alias ls='ls --color=auto'
        alias crontab='crontab -i'
        ;;
    CYGWIN*)
        alias ls='ls --color -F --show-control-chars'
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
exists wavemon   && alias xwavemon='env LANG=C xterm +sb -e wavemon'
alias od='od -tx1z -Ax -v' # http://d.hatena.ne.jp/maji-KY/20110718/1310985449
exists highlight && alias hl=highlight # http://search.cpan.org/dist/App-highlight/
# http://suzuki.tdiary.net/20140516.html#p01
if [ -f /usr/local/bin/highlight ] ; then
    alias syntaxhi=/usr/local/bin/highlight
fi

if [ -d /usr/local/Cellar/screenutf8 ] ; then
    #screenutf8_path=$(brew info screenutf8 | grep ^/usr/local/Cellar/screenutf8/ | sed -e 's/ .*//')
    screenutf8_path=/usr/local/Cellar/screenutf8/4.4.0
    if [ -n "$screenutf8_path" ] && [ -f "$screenutf8_path/bin/screen" ] ; then
        alias screenutf8=$screenutf8_path/bin/screen
        export SCREEN_COMMAND=$screenutf8_path/bin/screen
    else
        export SCREEN_COMMAND=screen
    fi
    export PHS_SCREEN_COMMAND=$SCREEN_COMMAND
    unset screenutf8_path
    alias screen=screenutf8
fi

###
### Perl
###
alias system-perldoc='/usr/bin/perldoc'
alias system-perl='/usr/bin/perl'
alias modperl-method='/usr/bin/perl -MModPerl::MethodLookup -e print_method'
alias modperl-object='/usr/bin/perl -MModPerl::MethodLookup -e print_object'
alias modperl-module='/usr/bin/perl -MModPerl::MethodLookup -e print_module'
alias perl-deparse='perl -MO=Deparse '
function perl-module { perl -M$1 -e 1 ; }
function perl-flymake { pfswatch -q $1 -e perl -wc $1 ; }
function perl-installed-modules { perl -MExtUtils::Installed -E 'say($_) for ExtUtils::Installed->new->modules' ; }
function perllv { perldoc -l $1 | xargs --no-run-if-empty lv ; }
alias uri_unescape='perl -MURI::Escape=uri_unescape -E "say uri_unescape(join q/ /, @ARGV)" '
alias uri_escape='perl -MURI::Escape=uri_escape -E "say uri_escape(join q/ /, @ARGV)" '
function perl-mods2newit-perlbrew {
    # function naming is irresponsible. I will change it's names.
    # see: https://delicious.com/ogata/perlbrew articles.
    arg=$1
    perlbrew list-modules | perlbrew exec --with $1 cpanm
}
# https://gist.github.com/hirose31/8647156
function pmver {
    if [ -z "$1" ] ; then
        echo "Usage:"
        echo "  pmver [-cd] MODULE_NAME"
        return
    fi
    local do_cd=false
    if [ "$1" = '-cd' ]; then
        do_cd=true
        shift
    fi
    local module=$1
    perl -M${module} -e "print \$${module}::VERSION,\"\n\""
    fullpath=$(
        perldoc -ml ${module} 2>/dev/null
        [ $? -eq  255 ] && perldoc -l ${module}
        )
    echo $fullpath
    if $do_cd ; then
        \cd $(dirname $fullpath)
    fi
}

function pwdhttpd {
    plackup -MCwd -MPlack::App::Directory "$@" \
        -e 'Plack::App::Directory->new({root=>getcwd()})->to_app'
}

alias dict='perl -MCocoa::DictionaryServices=lookup -le "print for lookup(@ARGV);"'
alias available_dictionaries='perl -MCocoa::DictionaryServices=available_dictionaries -le "print for available_dictionaries()"'

# complete -C perldoc-complete -o nospace -o default perldoc
# complete -C perldoc-complete -o nospace -o default pm
# complete -C perldoc-complete -o nospace -o default pv
# complete -C perldoc-complete -o nospace -o default pmgrep

#if [ -f /usr/local/Cellar/groff/1.22.2/bin/groff ] ; then
#    alias perldoc='perldoc -n /usr/local/Cellar/groff/1.22.2/bin/groff '
#fi

###
### Mac OS X
###
#if type growlnotify >/dev/null 2>&1 ; then
    #alias dialog='growlnotify -s -m '
    #alias notify='read line; growlnotify -m "$line"'
#fi
if [ "$UNAME" = Darwin ] ; then
    # Recommend to create symlink /usr/sbin/airport as the airport.
    if [ ! -f /sbin/airport ] || [ ! -f /usr/sbin/airport ] ; then
        alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
    fi
    alias airport-info='airport -I'
    function search-ssid {
        local ssid=$1
        if [ -z "$ssid" ] ; then
            echo "specify ssid as first argument" >&2
            return 1
        fi
        while true ; do
            airport -s | grep "$ssid"
            sleep 3
        done
    }
    function enpower {
        local switch="$1"
        if [ "$switch" != on ] && [ "$switch" != off ] ; then
            echo "Usage: $FUNCNAME [on|off]"
            return
        fi
        networksetup -setairportpower en0 $switch
    }
    alias ql='qlmanage -p 2>/dev/null'
    alias imgdim='sips -g pixelHeight -g pixelWidth $1'
    # see various-commands/alt-md5sum more.
    if type alt-md5sum >/dev/null 2>&1 && ! type md5sum >/dev/null 2>&1 ; then
        alias md5sum=alt-md5sum
    elif type md5 >/dev/null 2>&1 && ! type md5sum >/dev/null 2>&1 ; then
        alias md5sum='md5 -s '
    fi
    alias pbtee='cat | pbcopy ; sleep 1 ; pbpaste'
    #alias pbtee='cat | tee >(pbpaste)' # FIXME: does not work.
    alias pb-iconv-change='pbpaste | iconv -c -f UTF-8-MAC -t UTF-8 | pbcopy'
    alias pwdcopy='echo -n $(pwd)/ | pbcopy'
fi

# TODO: screen をログインシェルにしてもいいのでは？ → screen の new-screen で無限再帰になる危険性があるのでダメ
if ! type sc >/dev/null 2>&1 ; then
    function sc {
        case "$TERM" in
            screen*)
                screen "$@"
                ;;
            *)
                screen -xR "$@"
        esac
    }
fi

###
### X / KDE
###
if type dcop >/dev/null 2>&1 ; then
    alias mixer='dcop kmix kmix-mainwindow#1 show'
    alias mute='dcop kmix Mixer0 toggleMasterMute' # arg: "on" or "off"

    alias kding='test $? -eq 0 && ogg123 -q /usr/share/sounds/KDE_Event_1.ogg || ogg123 -q /usr/share/sounds/KDE_Event_5.ogg'
    alias ding='test $? -eq 0 && ogg123 -q /usr/share/sounds/KDE_Event_1.ogg || ogg123 -q /usr/share/sounds/KDE_Event_5.ogg'
fi
if type kdialog >/dev/null 2>&1 ; then
    alias kpopup='test $? -eq 0 && kdialog --msgbox 処理が完了しました || kdialog --error エラーコードを受けとりました '
    function kfinish {
        declare status=$?
        declare cmd=`history 1 | sed -e 's/^ *[[:digit:]]* *//'`
        kdialog --title "コマンドが終了しました" --msgbox "cmd=${cmd}\nstatus=$status"
    }
fi
if type xrandr >/dev/null 2>&1 ; then
    alias vga-display='xrandr --output VGA --mode 1024x768'
    alias lcd-display='xrandr --output LVDS --mode 1024x768'
fi
if type wavemon >/dev/null 2>&1 ; then
    alias xwavemon='env LANG=C xterm +sb -e wavemon'
fi
if type mlterm >/dev/null 2>&1 ; then
    alias ml-server="mlterm -j genuine"
    # If running ml-server at first, then use mlclient by mlterm subprocess up.
    alias mlclient-remote="mlclient --bg=black --fg=gray "
    alias mlclient-local="mlclient --bg=#EEEEE6 --title=local -e 'screen -xR $USER'"
fi
if type mlterm >/dev/null 2>&1 ; then
    alias mlt-local='mlterm --bg=#EEEEE6 --title=mlterm::local -e screen -xR konko'
    alias mlt-woody='mlterm --bg=black --fg=gray --title=mlterm::woody'
    alias mlt-tetsuji='mlterm --bg=black --fg=gray --title=mlterm::tetsuji.jp'
fi
if type krdc >/dev/null 2>&1 ; then
    alias krdc-castella='krdc -c -f -p $HOME/doc/passwd/castella.passwd -m localhost:1'
fi

###
### Cygwin
###
if [[ "$UNAME" =~ CYGWIN.* ]] ; then # Do not quote "=~"'s right side.
    alias halt='shutdown -s -f -t 0 '
    alias uptime='cat /proc/loadavg'
    alias hide-dotfile='for f in .??* ; do attrib +h ; done'
    alias cdcygdesktop='cd "$(cygpath -D)"'
    function cygcd {
        local arg dir
        arg="$1"
        if echo "$arg" | grep '^shell:' &>/dev/null 2>&1 ; then
            dir=$(getwssname "$arg")
        fi
        builtin cd "$dir"
    }
fi

###
### big functions
###

# attach-agent
# 再度アタッチした screen から、現在の ssh-agent に接続する
function attach-agent {
    if     [ $TERM != screen ]   \
    && [ $TERM != screen-w ] \
    && [ $TERM != mlterm ]   \
        && [ $TERM != screen.mlterm ] ; then
    return 1
    fi
    declare sock childpid
    for sock in $( find /tmp -type s -name agent.\* -user $USER 2> /dev/null ) ; do
    childpid=$( echo $sock | awk -F. '{ print $2 }' ) # ordinaly "sh"'s pid
    if ps ux | grep $childpid | grep -v grep > /dev/null ; then
#         eval $( ( cat /proc/$childpid/environ ; echo ) | tr "\000" "\n" | egrep ^SSH_AGENT_PID )
#         if [ -z $SSH_AGENT_PID ] ; then
#         echo "${FUNCNAME}: error! SSH_AGENT_PID unknonw"
#         unset SSH_AGENT_PID
#         return 1
#         elif ! ( ps ux | grep $SSH_AGENT_PID | grep -v grep > /dev/null ) ; then
#         echo "${FUNCNAME}: error! no process found corresponding SSH_AGENT_PID=$SSH_AGENT_PID"
#         unset SSH_AGENT_PID
#         return 1
#         fi
#         export SSH_AGENT_PID
        export SSH_AUTH_SOCK=$sock
        if ssh-add -l &> /dev/null ; then
        # unsetenv for old (woody) version screen.
#        screen -X unsetenv SSH_AGENT_PID
        if [ $TERM = screen ] || [ $TERM = screen-w ] || [ $TERM = screen.mlterm ] ; then
            #screen -X setenv SSH_AGENT_PID $SSH_AGENT_PID
            screen -X unsetenv SSH_AUTH_SOCK
            screen -X setenv SSH_AUTH_SOCK $SSH_AUTH_SOCK
        fi
        echo "OK, success that $TERM attaches to the ssh-agent!"
        echo "'ssh-add -l' output is..."
        ssh-add -l | sed -e 's;/[^[:space:]]*/;;'
        set | egrep ^SSH_
        return 0
        else
        unset SSH_AGENT_PID SSH_AUTH_SOCK
        fi
    fi
    done
    echo "screen-agent: no ssh-agent runs?"
    return 0
}

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
                xtcd.sh :help ; return
                ;;
            history)
                result="$( dirs -v | xtcd.sh :history "$@" )"
                ;;
            stdin)
                # 標準入力 + peco || select
                # この拡張 cd 自体が標準入力を取ってディレクトリ移動することはできない
                # cd :stdin "COMMAND" とする
                test $# = 0 && { echo -e "Usage:\n  cd :stdin COMMAND ARGS..." ; return 1 ; }
                result="$( "$@" | xtcd.sh :stdin "$@" )"
                ;;
            clear)
                dirs -c ; return
                ;;
            up|down|which|pwdsed|repo)
                result="$( xtcd.sh :$subcommand "$@" )"
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
    pushd "$result" >/dev/null
    #set +x
}

# chcvsroot: CVSROOT 環境変数を変更して export する
function chcvsroot {
    declare arg desc dir i
    arg="$1"
    # CHCVSROOT_MAP array Example. I define in ~/.bash_secret
#     CHCVSROOT_MAP=(
#         "local"    "~/var/cvs"
#         "intra"  ":pserver:username@cvs.intra.example.jp:/var/cvs"
#         "outdev" ":ext:username@cvs.example.com:/var/cvsroot"
#   );
    if [ "$arg" = "-h" ] ; then
        echo "Usage: $FUNCNAME "
        echo "  $FUNCNAME"
        echo "  $FUNCNAME [-h|-l]"
        echo "  $FUNCNAME <cvsroot_alias>"
        return
    elif [ "$arg" = "-l" ] ; then
        for (( i=0; $i<${#CHCVSROOT_MAP[*]}; i=$((i+2)) )) ; do
            desc=${CHCVSROOT_MAP[$i]}
            dir=${CHCVSROOT_MAP[$((i+1))]}
            printf "%8s => %s\n" $desc $dir
        done
        return
    elif [ -z "$arg" ] ; then
        for (( i=0; $i<${#CHCVSROOT_MAP[*]}; i=$((i+2)) )) ; do
            desc=${CHCVSROOT_MAP[$i]}
            dir=${CHCVSROOT_MAP[$((i+1))]}
            printf '%3d %8s %s%b\n' $((i/2)) $desc $dir
        done
        read -p "select number: " i
        if [ -z "$i" ] ; then
            echo "chcvsroot: Abort." 1>&2
            return 1
        fi
        dir=${CHCVSROOT_MAP[$((i*2+1))]}
        if [ -z "$dir" ] ; then
            echo "directory is not defined" 1>&2
            return 1
        fi
        export CVSROOT="$dir"
        return
    else
        for (( i=0; $i<${#CHCVSROOT_MAP[*]}; i=$((i+2)) )) ; do
            desc=${CHCVSROOT_MAP[$i]}
            dir=${CHCVSROOT_MAP[$((i+1))]}
            if [ "$desc" = "$arg" ] ; then
                echo "export CVSROOT=$dir"
                export CVSROOT="$dir"
                return
            fi
        done
    fi
    echo "argument is not recognized."
}

# chproxy
# http proxy 関連の環境変数を変更して export する
function chproxy {
    declare i num desc proxy
    echo "currently http_proxy is ..."
    env | grep -i _proxy | sed -e 's/^/  > /'
    echo ""
    # CHPROXYT_MAP array Example. I define in ~/.bash_secret
#     CHPROXY_MAP=(
#         "portforward" "http://localhost:8080/"
#         "company"     "http://proxy.example.co.jp:80/"
#   );
    for (( i=0; $i<${#CHPROXY_MAP[*]}; i=$((i+2)) )) ; do
        desc=${CHPROXY_MAP[$i]}
        proxy=${CHPROXY_MAP[$((i+1))]}
        printf '%3d %16s %s%b\n' $((i/2)) $desc $proxy
    done
    read -p "select number: " num
    if [ -z "$num" ] ; then
        echo "$FUNCNAME: Abort Input number." 1>&2
        return 1
    else
        echo "$num" | grep '[^[:digit:]]' && \
            { echo "$FUNCNAME: Abort. Invalid input." 1>&2 ; return ; }
        proxy=${CHPROXY_MAP[$((num*2+1))]}
        echo "Set proxy to $proxy"
        # NOTE: HTTP_PROXY (All uppercase "HTTP_PROXY" is not recommended.)
        export http_proxy=$proxy
        export HTTPS_PROXY=$proxy
        export https_proxy=$proxy
        export FTP_PROXY=$proxy
        if [ -z "$NO_PROXY" ] ; then
            # comma-separated list of hosts
            export NO_PROXY=localhost,127.0.0.1
            export no_proxy="$NO_PROXY"
        fi
        return
    fi
}

function reset-proxyenv {
    # NOTE: HTTP_PROXY (All uppercase "HTTP_PROXY" is not recommended.)
    unset HTTP_PROXY
    unset http_proxy
    unset HTTPS_PROXY
    unset https_proxy
    unset FTP_PROXY
    unset ftp_proxy
    unset NO_PROXY
    unset no_proxy
}

function show-proxyenv {
    env | grep -i _proxy
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

# killjobs - peco による jobs の kill
# jobs2 が上位互換となっています
function killjobs {
    local jobnumbers
    local arg="$1"
    jobnumbers=$( jobs | peco | sed -e 's/^\[//' -e 's/\].*//' -e 's/^/%/' )
    if [ ! -z "$jobnumbers" ] ; then
        kill $arg $jobnumbers
    fi
}

# killps - peco による ps リストからの kill
# ps2 が上位互換となっています
function killps {
    local killpids
    local arg="$1"
    killpids=$( ps auxwww | peco | perl -ne 'print grep { /^\d+$/ } +(split /\s+/)[1], "\n";' )
    if [ ! -z "$killpids" ] ; then
        kill $arg $killpids
    fi
}

# fgp - peco による fg
# jobs2 が上位互換です
function fgp {
    local jobnumber
    jobnumber=$( jobs | peco | sed -e 's/^\[//' -e 's/\].*//' -e 's/^/%/' )
    if [ ! -z "$jobnumber" ] ; then
        fg $jobnumber
    fi
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

# openfind
# find した結果を peco で選別して open
function openfind () {
    if [ -z "$1" ] || [ "x$1" = "x-h" ] ; then
        echo "Usage: $FUNCNAME find_argument..."
        return
    fi
    local arg=$(find "$@" | peco)
    open "$arg"
}

# ssh と tail を使った簡単リモート通知
# ただ使い方が面倒
# http://d.hatena.ne.jp/punitan/20110416/1302928953
# 2011/12/16
# 今は srnotifyd と srnotify.pl を使っている
function snotifyd {
    declare host remote_log line
    declare -r IMAGE_PATH=$HOME/Pictures/min_x40_mini.png
    host=$1
    if [ -z "$host" ] ; then
        echo "snotify host [remote_log]"
        return 1
    fi
    remote_log=$2
    if [ -z "$remote_log" ] ; then
        remote_log='$HOME/log/growler.log'
    fi
    echo "start snotify to $host:$remote_log"
    ssh $host env LANG=C tail -q -n 0 -F "$remote_log" \
        | while read line ; do echo "$line" ; growlnotify -s -m "$line" -t $host ; done
    #| perl -e 'system qw/growlnotify -s -m/, $_, '$host' while <STDIN>;'
}


# 現在のディレクトリにいた記録を取ってタスクとして記憶
# chkd => リストモードで選ばせる
# chked delete => リストモードで選ばせたものを削除する
# chkd -m MEMO
# chkd --memory MEMO => 現在のディレクトリをMEMO付きで覚えさせる
function chkd {
    local arg="$1"
    local listfile="$HOME/.chkdlist"
    local mode subarg directory comment
    if [ -z "$arg" -o "x$arg" = x--delete -o "x$arg" = x-d ] ; then
        mode=list
        test -n "$arg" && arg=delete || arg=select
    elif [ "x$arg" = x--help -o "x$arg" = x-h ] ; then
        echo "Usage:"
        echo "  $FUNCNAME                    => List mode"
        echo "  $FUNCNAME [-d|--delete]      => List and delete mode"
        echo "  $FUNCNAME [-h|--help]        => Help (This message)"
        echo "  $FUNCNAME [-m|--memory] MEMO => Memo This Directory"
        return
    elif [ "x$arg" = x-m -o "x$arg" = x--memory ] ; then
        mode=memory
        subarg="$2"
    fi
    if [ $mode = list ] ; then
        if [ ! -s "$listfile" ] ; then
            echo "list file \"$listfile\" is not found or empty" >&2
            return 1
        fi
        # show and select
        if type peco >/dev/null 2>&1 ; then
            line=$(peco --prompt "$arg memo>" "$listfile")
            if [[ $(echo $line | wc -l) > 1 ]] ; then
                echo "Currently non-support multiple select."
                return
            fi
            # TODO: multiple select
        else

            cat "$listfile"
            read -t 10 -p "input line number> " line_number
            echo $line_number | grep '^[0-9]+$' >/dev/null 2>&1 ||
                { echo "Please input number" >&2 ; return 1 ; }
            line=$(cat "$listfile" | sed -ne "${line_number}p")
        fi
        if [ -n "$line" ] ; then # $line is non-zero
            # include TAB code
            directory="${line/	*/}"
            comment="${line/*	/}"
            if [ "$arg" = delete ] ; then
                # その行以外をもう一度書き戻す
                grep --extended-regexp --invert-match "^$directory\t" $listfile > $listfile.tmp
                # ここのよりわけも行数把握して sed がいいな
                rm -f $listfile
                mv $listfile.tmp $listfile
                echo "delete done"
                return
            else
                #echo -e "change directory to \e[34;1m${directory}\e[m by \e[32;1m${comment}\e[m."
                echo "change directory to ${directory} by ${comment}."
                cd "$directory"
            fi
        else
            echo "Selected line is not found."
        fi
    elif [ $mode = memory ] ; then
        # 末尾改行いるのかいらないのかどうだっけな
        echo -e "$(pwd)\t$subarg" >> $listfile
    else
        echo "Mode detect faild" 2>&1
    fi
}

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
