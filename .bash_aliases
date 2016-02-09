# -*- mode: shell-script ; coding: utf-8 ; -*-

declare ALIASES=$HOME/.bash_aliases
declare UNAME=$(uname)

function my {
    echo "Usage:"
    echo "  my-starup"
    echo "  my-ssh-add"
    echo "  my-alias-help"
    echo "  my-init-backgrounds"
    echo "  # my-ssh-agent-setup"
}

# my-alias-help
# grep function .bash_aliases | perl -ne '/function +(\S+)/ and print "$1\n"' | sort | xargs echo
function my-alias-help {
    perl -ne 'push @funcs, /^function +([\w-]+)/; END { print "@funcs\n"; }' .bash_aliases
}

function my-startup {
    if [ "$MY_STARTUP_DONE" = 1 ] ; then
	echo "alread done"
	return
    fi
    my-ssh-add
    MY_STARTUP_DONE=1
}

function my-init-backgrounds {
    battery-watchd &
    macwland &
    pbstot2memod &
    srnotifyd &
    disk-capad &
}

###
### Basics
###

case "$UNAME" in
    Darwin) ### Mac OS X
	alias ls='ls -FG' # BSD type "ls"
	alias lsx='ls -xG'
	# see: http://ascii.jp/elem/000/000/594/594203/
	alias CharacterPalette='open /System/Library/Input\ Methods/CharacterPalette.app/'
	alias ArchiveUtility='open /System/Library/CoreServices/Archive\ Utility.app/'
	alias iPhoneSimulator='open /Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	alias battery-remaining='pmset -g ps'
        alias quicktime="open -a 'QuickTime Player' "
	test -f /Applications/Emacs.app/Contents/MacOS/bin/emacsclient && \
	    alias emacsclient="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
	type gtar >/dev/null 2>&1 && alias tar=gtar
    # see: http://deeeet.com/writing/2014/04/30/beer-on-terminal/
        function beers () { ruby -e 'C=`stty size`.scan(/\d+/)[1].to_i;S=ARGV.shift||"\xf0\x9f\x8d\xba";a={};puts "\033[2J";loop{a[rand(C)]=0;a.each{|x,o|;a[x]+=1;print "\033[#{o};#{x}H \033[#{a[x]};#{x}H#{S} \033[0;0H"};$stdout.flush;sleep 0.01}' ; }
	;;
    Linux)
	alias ls='ls --color=auto'
	alias lsx='ls -x --color=always'
	alias crontab='crontab -i'
	;;
    CYGWIN*)
        alias ls='ls --color -F --show-control-chars'
        ;;
    *)
        ;;
esac
if ! type lst >/dev/null 2>&1 ; then
    alias lst='ls -t'
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias lv='lv -c'
if ! type lv >/dev/null 2>&1 && type less >/dev/null 2>&1 ; then
    alias lv='echo "lv is aliased as less" 1>&2 ; less'
fi
# -N for showing multibytes character
alias tree='tree -NC'
alias mv='mv -i'
alias en='env LANG=C '
if type w3m >/dev/null 2>&1 ; then
    alias htmlv='w3m -T text/html '
fi
function ymd {
    sep=$1
    env LANG=C date +"%Y${sep}%m${sep}%d"
}
function hms {
    sep=$1
    env LANG=C date +"%H${sep}%M${sep}%S"
}
alias cldate="en date +'%a %b %d %T %Y'"
alias epoch='date +%s'
function exists { type $1 >/dev/null 2>&1 ; return $? ; }

function extcount {
    local dir="${1:-.}"
    find "$dir" -type f |  sed -e 's/.*\.//' | grep -v '/' | sort | uniq -c | sort -rnk1
    # TODO: detection no-having-extension file and dotfile.
}

if type git >/dev/null 2>&1 && type hub >/dev/null 2>&1 ; then
    alias git=hub
fi

function init-git-flavor {
    # TODO: Does pager recognized color sequence?
    git config --global push.default simple
    # true or false?
    git config --global color.ui true
    git config --global alias.graph "log --graph --date-order --all --pretty=format:'%h %Cred%d %Cgreen%ad %Cblue%cn %Creset%s' --date=short" 
}

alias dachoclub="ionice -c2 -n7 nice -n 19 "

###
### Utilities
###
alias portscan='nmap -sT -p1-65535 ' # argument: hostname
if type colordiff >/dev/null 2>&1 ; then
    alias diff=colordiff
fi
if type xwavemon >/dev/null 2>&1 ; then
    alias xwavemon='env LANG=C xterm +sb -e wavemon'
fi

# invert of "bg" command
if ! type stop >/dev/null 2>&1 ; then
    alias stop='kill -STOP '
elif ! type sigstop >/dev/null 2>&1 ; then
    alias sigstop='kill -STOP '
fi
if ! type cont >/dev/null 2>&1 ; then
    alias cont='kill -CONT '
elif ! type sigcont >/dev/null 2>&1 ; then
    alias sigcont='kill -CONT '
fi

alias append-quote='sed -e "s/^/> /"'
alias remove-quote='sed -e "s/^> //"'

alias find-backups='find . -maxdepth 1 -name "?*~" -o -name "?*.bak" -o -name ".[^.]?*~" -o name ".[^.]*.bak"'

if type emacsclient >/dev/null 2>&1 && ! type ec >/dev/null 2>&1 ; then
    alias ec=emacsclient
fi
function edit {
    local arg="$1"
    if [ -z "$arg" ] ; then
        echo "$FUNCNAME argument"
        return
    fi
    emacsclient $arg &
}

alias sslv3='curl -sslv3 -kv '

# see: http://d.hatena.ne.jp/maji-KY/20110718/1310985449
alias od='od -tx1z -Ax -v'

alias reload='source ~/.bash_profile'
alias gip="curl -s checkip.dyndns.org | sed -e 's/.Current IP Address: //' -e 's/<.$//'"
alias clocktick='while :; do printf "%s\r" "$(date +%T)"; sleep 1 ; done'

function various-hostname {
    echo "hostname command:"
    echo "  `hostname`"
    echo "perl \$Config{myhostname}:"
    perl -MConfig -e 'print "  $Config{myhostname}\n"'
    # see: http://ekbo.blogspot.jp/2013/10/mac-scutil.html
    echo "scutil --get LocalHostName:"
    echo "  `scutil --get LocalHostName`"
    echo "scutil --get ComputerName:"
    echo "  `scutil --get ComputerName`"
}

# debug
# debug on
# debug off
function debug {
    local arg="$1"
    if [ "x$arg" = "x--help" ] ; then
        echo "Usage:"
        echo "  debug"
        echo "  debug on"
        echo "  debug off"
        return
    fi
    if [ -z "$arg" ] ; then
        echo "DEBUG is:"
        echo $DEBUG
    elif [ "$arg" = off -o "$arg" = "0" ] ; then
        echo "unset DEBUG."
        DEBUG=
        unset DEBUG
    elif [ "$arg" = on -o "$arg" = "1" ] ; then
        echo "set DEBUG."
        export DEBUG=1
    fi
}

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

# http://search.cpan.org/dist/App-highlight/
if type highlight >/dev/null 2>&1 && ! type hl >/dev/null 2>&1 ; then
    alias hl=highlight
fi

# http://suzuki.tdiary.net/20140516.html#p01
if [ -f /usr/local/bin/highlight ] ; then
    alias syntaxhi=/usr/local/bin/highlight
fi

function jsonlv {
    # TODO: plural arguments
    local command arg
    arg="$1"
    if type json_xs >/dev/null 2>&1 ; then
        command=json_xs
    elif type json_pp >/dev/null 2>&1 ; then
        command=json_pp
    else
        # :-(
        command=cat
    fi
    $command <"$arg" | lv
}

alias dict='perl -MCocoa::DictionaryServices=lookup -le "print for lookup(@ARGV);"'
alias available_dictionaries='perl -MCocoa::DictionaryServices=available_dictionaries -le "print for available_dictionaries()"'

function module-view() {
    [ -n "$1" ] && perldoc -m $1
}

function module-version() {
    [ -n "$1" ] && perl -e "use $1;print qq|$1: \$$1::VERSION\n|;";
}

function pmgrep() {
    local PAGER_LOCAL=$PAGER
    if [ -n "$PAGER_LOCALE " ] ; then
        PAGER_LOCAL='less -r'
    fi
    [ -n "$1" ] && [ -n "$2" ] && \
        grep --context=3 --line-number "$1" `perldoc -l $2` | $PAGER_LOCAL;
}

# complete -C perldoc-complete -o nospace -o default perldoc
# complete -C perldoc-complete -o nospace -o default pm
# complete -C perldoc-complete -o nospace -o default pv
# complete -C perldoc-complete -o nospace -o default pmgrep

#if [ -f /usr/local/Cellar/groff/1.22.2/bin/groff ] ; then
#    alias perldoc='perldoc -n /usr/local/Cellar/groff/1.22.2/bin/groff '
#fi

###
### SSH
###
# "~/.ssh/keylist.txt" has private key filename per line.
alias my-ssh-add='for key in $(grep -v "^ *#" ~/.ssh/keylist.txt) ; do ssh-add ~/.ssh/$key ; done ; unset key'
alias ssh-keylist="ssh-add -l | sed -e 's;/[^[:space:]]*/;;'"
alias hup-autossh='killall -HUP autossh ; killall -USR1 autossh ; '
alias my-ssh-agent-setup='if ps ux | grep ssh-[a]gent >/dev/null 2>&1 ; then echo "ssh-agent already run" ; else eval $(ssh-agent) ; my-ssh-add ; fi'

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
    alias ssid='airport-info | grep " SSID: " | sed -e "s/.* //"'
    alias CharacterPalette='open /System/Library/Input\ Methods/CharacterPalette.app/'
    alias ArchiveUtility='open /System/Library/CoreServices/Archive\ Utility.app/'
    alias iPhoneSimulator='open /Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
    alias cocoa-screenshare='open "/System/Library/CoreServices/Screen\ Sharing.app/"'
    alias ql='qlmanage -p 2>/dev/null'
    alias mute='/usr/bin/osascript -e "set volume 0"'
    alias imgdim='sips -g pixelHeight -g pixelWidth $1'
    # see various-commands/alt-md5sum more.
    if type alt-md5sum >/dev/null 2>&1 && ! type md5sum >/dev/null 2>&1 ; then
        alias md5sum=alt-md5sum
    elif type md5 >/dev/null 2>&1 && ! type md5sum >/dev/null 2>&1 ; then
        alias md5sum='md5 -s '
    fi
    alias pbtee='cat | pbcopy ; sleep 1 ; pbpaste'
    #alias pbtee='cat | tee >(pbpaste)' # FIXME: does not work.
    alias pb-append-quote='pbpaste | append-quote | pbcopy'
    alias pb-remove-quote='pbpaste | remove-quote | pbcopy'
    alias pb-iconv-change='pbpaste | iconv -c -f UTF-8-MAC -t UTF-8 | pbcopy'
    alias pwdcopy='echo -n $(pwd)/ | pbcopy'
fi

alias term-growl='killall -TERM Growl HardwareGrowler'

# TODO: screen をログインシェルにしてもいいのでは？
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
# 	    eval $( ( cat /proc/$childpid/environ ; echo ) | tr "\000" "\n" | egrep ^SSH_AGENT_PID )
# 	    if [ -z $SSH_AGENT_PID ] ; then
# 		echo "${FUNCNAME}: error! SSH_AGENT_PID unknonw"
# 		unset SSH_AGENT_PID
# 		return 1
# 	    elif ! ( ps ux | grep $SSH_AGENT_PID | grep -v grep > /dev/null ) ; then
# 		echo "${FUNCNAME}: error! no process found corresponding SSH_AGENT_PID=$SSH_AGENT_PID"
# 		unset SSH_AGENT_PID
# 		return 1
# 	    fi
# 	    export SSH_AGENT_PID
	    export SSH_AUTH_SOCK=$sock
	    if ssh-add -l &> /dev/null ; then
		# unsetenv for old (woody) version screen.
#		screen -X unsetenv SSH_AGENT_PID
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

# 履歴を記録する cd の再定義
# Initial release at 2005/03/22(Tue)
function cd {
    if [ -z "$1" ] ; then
	# cd 連打で余計な $DIRSTACK を増やさない
	test "$PWD" != "$HOME" && pushd $HOME > /dev/null
    elif ( echo "$1" | egrep "^\.\.\.+$" > /dev/null ) ; then
	cd $( echo "$1" | perl -ne 'print "../" x ( tr/\./\./ - 1 )' )
    else
        if [ "x$1" = "x-p" ] && [ -n "$2" ] ; then
            mkdir -v -p "$2"
            pushd "$2" >/dev/null
        else
	    pushd "$1" > /dev/null
        fi
    fi
}

# 最近の cd によって移動したディレクトリを選択
function cdhist {
    local dirnum
    #dirs -v | head -n $(( LINES - 3 ))
    dirs -v | sort -k 2 | uniq -f 1 | sort -n -k 1 | head -n $(( LINES - 3 ))
    read -p "select number: " dirnum
    if [ -z "$dirnum" ] ; then
	echo "$FUNCNAME: Abort." 1>&2
    elif ( echo $dirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
        cd "$( echo ${DIRSTACK[$dirnum]} | sed -e "s;^~;$HOME;" )"
        echo "Prefer cdh over cdhist by peco"
    else
	echo "$FUNCNAME: Wrong." 1>&2
    fi
}

# cdhist の peco 版
type peco >/dev/null 2>&1 &&
function cdh {
    local dir
    dir="$( dirs -v | sort -k 2 | uniq -f 1 | sort -n -k 1 | sed -e 's/^ *[0-9]* *//' | peco | sed -e "s;^~;$HOME;" )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}

# 現在のディレクトリの中にあるディレクトリを番号指定で移動
function cdlist {
    local -a dirlist opt_f=false
    local i d num=0 dirnum opt opt_f
    while getopts ":f" opt ; do
	case $opt in
	    f ) opt_f=true ;;
	esac
    done
    shift $(( OPTIND -1 ))
    dirlist[0]=..
    # external pipe scope. array is established.
    for d in * ; do test -d "$d" && dirlist[$((++num))]="$d" ; done
    # TODO: Is seq installed?
    for i in $( seq 0 $num ) ; do printf "%3d %s%b\n" $i "$( $opt_f && echo -n "$PWD/" )${dirlist[$i]}" ; done
    read -p "select number: " dirnum
    if [ -z "$dirnum" ] ; then
	echo "$FUNCNAME: Abort." 1>&2
    elif ( echo $dirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
	cd "${dirlist[$dirnum]}"
        echo "Prefer cdl over cdlist by peco"
    else
	echo "$FUNCNAME: Something wrong." 1>&2
    fi
}

# cdlist の peco 版
type peco >/dev/null 2>&1 &&
function cdl {
    local dir
    dir="$( find . -maxdepth 1 -type d | sed -e 's;^\./;;' | grep -v '^\.$' | peco )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}

function cdback {
    #popd $1 >/dev/null
    local num=$1 i
    if [ -z "$num" -o "$num" = 1 ] ; then
        popd >/dev/null
        return
    elif [[ "$num" =~ ^[0-9]+$ ]] ; then
        for (( i=0 ; i<num ; i++ )) ; do
            popd >/dev/null
        done
        return
    else
        echo "cdback: argument is invalid." >&2
    fi
}

alias cdclear='dirs -c'

### ad-hoc chdir like aliases 
# alias ,=cdback
# alias ..="cd .."
# alias ...=".. ; ..;"
# alias ....="..; ..; ..;"
# alias .....="..; ..; ..; ..;"
# alias ......="..; ..; ..; ..; ..;"

# Jump cd as shortcut key.
function cdj {
    ### cdj needs CDJ_DIR_MAP array definition:
    # CDJ_DIR_MAP array Example. I define in ~/.bash_secret
#     CDJ_DIR_MAP=(
#         dbox ~/Dropbox
#         cvs  ~/cvs
#         etc  /etc
#         );
    test -n "$DEBUG" && echo "DEBUG: dir arg=$arg #CDJ_DIR_MAP=${#CDJ_DIR_MAP[*]}" 
    declare arg=$1 \
            subarg=$2 \
            dir i key value warn
    if [ -z "$arg" -o "$arg" = "-h" ] || [ "$arg" = "-v" -a -z "$subarg" ] ; then
        ### help and usage mode
        echo "Usage: $FUNCNAME <directory_alias>"
        echo "       $FUNCNAME [-h|-v|-l <directory_alias>]"
        echo "-h: help"
        echo "-l: list defined lists"
        echo "-v <directory_alias>: view path specify alias."
        return
    elif [ "$arg" = "-v" -o "$arg" = "-l" ] ; then 
        ### view detail mode
        for (( i=0; $i<${#CDJ_DIR_MAP[*]}; i=$((i+2)) )) ; do
            key="${CDJ_DIR_MAP[$i]}"
            value="${CDJ_DIR_MAP[$((i+1))]}"
            if [ "$arg" = "-l" ] ; then
                if [ ! -d "$value" ] ; then
                    warn=" ***NOT_FOUND***"
                else
                    warn=""
                fi
                printf "%8s => %s%s\n" "$key" "$value" "$warn"
            elif [ "$arg" = "-v" ] ; then
                if [ "$key" = "$subarg" ] ; then
                    echo $value
                    return
                fi
            fi
        done
        return
    fi
    ### change directory mode
    for (( i=0; $i<${#CDJ_DIR_MAP[*]}; i=$((i+2)) )) ; do
        key="${CDJ_DIR_MAP[$i]}"
        value="${CDJ_DIR_MAP[$((i+1))]}"
        test -n "$DEBUG" && echo "$key => $value"
        if [ "$key" = "$arg" ] ; then
            if [ -n "$subarg" ] ; then
                dir="$value/$subarg"
	    else
                dir="$value"
            fi
            cd "$dir"
            return
        fi
    done
    echo "directory alias \"$arg\" is not found"
    return 1
}

# cdup
# ディレクトリをリスト化して上層へたどれる
function cdup {
    local -a dirlist
    local dirstr="$PWD" num=0 i dirnum
    while [ ! -z "$dirstr" ] ; do
        dirlist[$((++num))]="$dirstr"
        dirstr="${dirstr%/*}"
    done
    dirlist[$((++num))]=/
    for i in $( seq 1 $num ) ; do
        printf "%3d %s\n" $i "${dirlist[$i]}"
    done
    read -p "select number: " dirnum
    if [ -z "$dirnum" ] ; then
        echo "$FUNCNAME: Abort." 1>&2
    elif ( echo $dirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
        cd "${dirlist[$dirnum]}"
        echo "Prefer cdu over cdup by peco"
    else
        echo "$FUNCNAME: Something wrong." 1>&2
    fi
}

# cdup の peco 版
function cdu {
    local dir
    local dirstr="$PWD" num=0 i dirnum
    while [ ! -z "$dirstr" ] ; do
        dirlist[$((++num))]="$dirstr"
        dirstr="${dirstr%/*}"
    done
    dirlist[$((++num))]=/
    dir=$( for i in $( seq $num -1 1 ) ; do echo "${dirlist[$i]}" ; done | peco )
    test ! -z "$dir" && cd "$dir"
}

# which したコマンドの場所に cd
function cdwhich {
    arg="$1"
    cd $( dirname $( which "$arg" ) )
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

function pathclean {
    export PATH="$( perl -e 'my @paths = split /::*/, $ENV{PATH}; my (%seen, @new_paths); for (@paths) { if(!$seen{$_}++ && -d $_) { push @new_paths, $_; } } print join q(:), @new_paths' )"
}

function pathview {
    perl -e 'print join q(), map { qq($_\n) } split /:+/, $ENV{PATH}; '
}

# http://qiita.com/items/2a4dc1d6862da2af0972
function greppath() {
    local FOUND=0
    local IFS=':'
    local DIR
    for DIR in ${2}; do
        [ "${1}" == "${DIR}" ] && FOUND=1
    done
    [ ${FOUND} -ge 1 ] && echo "${1}" && return 0 || return 1
}

# cdlocate
# cd shortcut by locate
type locate >/dev/null 2>&1 && \
function cdlocate {
    local arg="$1" path i=0 j selnum selpath OUTPUT
    declare -a pathes
    if [ -z "$arg" ] || [ "$arg" = "-h" ] ; then
        echo "Usage:"
        echo "  $FUNCNAME STRING"
        return
    fi
    # mdfind search is case insensitive
    for path in $(locate "$arg" | grep -i -E "/[^/]*$arg[^/]*$" | sed -e 's/ /+/g') ; do
        path=$(echo "$path" | sed -e 's/\+/ /g')
        test -d "$path" || continue
        i=$((i+1))
        pathes[$i]="$path"
    done
    if [ -z "${pathes[1]}" ] ; then
        # Nothing search result.
        return
    fi
    if [ $i -ge $LINES ] ; then
        OUTPUT=$PAGER
        test -z "$OUTPUT" && OUTPUT=cat
    else
        OUTPUT=cat
    fi
    for j in $(seq 1 $i) ; do
        printf "%2d: %s\n" $j "${pathes[$j]}"
    done | $OUTPUT
    read -p "select number: " selnum
    selpath="${pathes[$selnum]}"
    if [ -z "$selpath" ] ; then
        echo "$FUNCNAME: select is wrong." 1>&2
        return 1
    fi
    cd "$selpath"
}

# cdlocate の peco 版
type loate >/dev/null 2>&1 && type peco >/dev/null 2>&1 &&
function cdlocatep {
    # not write yet ...
    :
}

# cdmd
# cd shortcut by mdfind (Mac OS X Spotlight CLI)
type mdfind >/dev/null 2>&1 && \
function cdmdfind {
    local arg="$1" path i=0 j selnum selpath OUTPUT
    declare -a pathes
    if [ -z "$arg" ] || [ "$arg" = "-h" ] ; then
        echo "Usage:"
        echo "  $FUNCNAME STRING"
        return
    fi
    # mdfind search is case insensitive
    for path in $(mdfind -name "$arg" | sed -e 's/ /+/g') ; do
        path=$(echo "$path" | sed -e 's/\+/ /g')
        test -d "$path" || continue
        i=$((i+1))
        pathes[$i]="$path"
    done
    if [ -z "${pathes[1]}" ] ; then
        # Nothing search result.
        return
    fi
    if [ $i -ge $LINES ] ; then
        OUTPUT=$PAGER
        test -z "$OUTPUT" && OUTPUT=cat
    else
        OUTPUT=cat
    fi
    if [ $i = 1 ] ; then
        cd ${pathes[1]}
        return
    fi
    for j in $(seq 1 $i) ; do
        printf "%2d: %s\n" $j "${pathes[$j]}"
    done | $OUTPUT
    read -p "select number: " selnum
    selpath="${pathes[$selnum]}"
    if [ -z "$selpath" ] ; then
        echo "$FUNCNAME: select is wrong." 1>&2
        return 1
    fi
    cd "$selpath"
}

# cdmdfind の peco 版
type peco >/dev/null 2>&1 && type mdfind >/dev/null 2>&1 &&
function cdmdfindp {
    local dir
    local arg="$1"
    if [ -z "$arg" ] || [ "$arg" = "-h" ] ; then
        echo "Usage:"
        echo "  $FUNCNAME STRING"
        return
    fi
    # TODO: クエリがなかった場合のエラー文言
    dir="$( mdfind -name "$arg" | perl -ne 'chomp; -d and print "$_\n";' | peco )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}

if type  mdfind >/dev/null 2>&1 ; then
    alias cdi=cdmdfindp
elif type locate >/dev/null 2>&1 ; then
    alias cdi=cdlocatep
fi

# pwdscd - 現在のディレクトリを置換する
# pwd -> s/// -> cd
function pwdscd {
    local pattern="$1" string="$2"
    return cd "${PWD/$pattern/$string}"
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
    read -p "Choice [fg|bg|cont|stop|disown|kill|SIG***|NUMBER|^C]: " choice
    jobspec=$(<<<"$line" sed -e 's/^\[/%/' -e 's/\].*//')
    case $choice in
        fg|bg|disown|kill)
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
    read -p "Choice [kill|SIG***|pbcopy]: " choice
    case $choice in
        kill)
            $choice -HUP $pid
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

# cdfind / findcd
# find した結果を peco で選別して cd
function cdfind () {
    if [ -z "$1" ] || [ "x$1" = "x-h" ] ; then
        echo "Usage: $FUNCNAME find_argument..."
        return
    fi
    local dir=$(find "$@" -type d | peco)
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}

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

function cdrepo {
    local dir=$1
    local line
    if [ -z "$dir" ] ; then
        dir=~
    fi
    line=$( find "$dir" -maxdepth 4 -name .git -type d | sed -e "s#^$HOME#~#" -e 's#/\.git$##' -e 's#//##g '| peco )
    # 空白ディレクトリ対策だけど、これだと ~ が展開されないので
    # cd "$line"
    cd "${line/'~'/$HOME}"
}

function http-get-source {
    local url=$1
    local file=$2
    if [ ! -f $file ] ; then
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
