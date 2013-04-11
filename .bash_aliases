# -*- shell-script -*-

declare ALIASES=$HOME/.bash_aliases
declare UNAME=$(uname)

###
### Basics
##
case "$UNAME" in
    Darwin) ### Mac OS X
	alias ls='ls -FG' # BSD type "ls"
	alias lsx='ls -xG'
	# see: http://ascii.jp/elem/000/000/594/594203/
	alias CharacterPalette='open /System/Library/Input\ Methods/CharacterPalette.app/'
	alias ArchiveUtility='open /System/Library/CoreServices/Archive\ Utility.app/'
	alias iPhoneSimulator='open /Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	;;
    Linux)
	alias ls='ls --color=auto'
	alias lsx='ls -x --color=always'
	;;
esac

alias lv='lv -c'
alias tree='tree -C'
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
alias epoch='date +%s'
function exists { type $1 >/dev/null 2>&1 ; return $? ; }

###
### Utilities
###
alias wol-sanporoku='wakeonlan 00:26:18:4F:85:DF'
alias wol-castella='wakeonlan 00:26:18:4F:85:DF'
alias portscan='nmap -sT -p1-65535 ' # argument: hostname
if type colordiff >/dev/null 2>&1 ; then
    alias diff=colordiff
fi
if type xwavemon >/dev/null 2>&1 ; then
    alias xwavemon='env LANG=C xterm +sb -e wavemon'
fi

alias iphone-wget='wget --user-agent="Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7" '

alias usr1='kill -USR1 '
alias usr2='kill -USR2 '

alias append-quote='sed -e "s/^/> /"'
alias remove-quote='sed -e "s/^> //"'

###
### Perl
###
alias modperl-method='/usr/bin/perl -MModPerl::MethodLookup -e ModPerl::MethodLookup::print_method '
alias perl-deparse='perl -MO=Deparse '
function perl-module { perl -M$1 -e 1 ; }
function perl-flymake { pfswatch -q $1 -e perl -wc $1 ; }
function perl-installed-modules { perl -MExtUtils::Installed -E 'say($_) for ExtUtils::Installed->new->modules' ; }
alias uri-unescape='perl -MURI::Escape=uri_unescape -E "say uri_unescape(join q/ /, @ARGV)" '
alias uri-escape='perl -MURI::Escape=uri_escape -E "say uri_escape(join q/ /, @ARGV)" '
alias suddenly_death='perl -MAcme::SuddenlyDeath -E "say suddenly_death(@ARGV)"'

###
### SSH
###
alias my-ssh-add='ssh-add ~/.ssh/{id_dsa,nvlocal,ffpartner,jitakulocal,sakura_vps,root-waffle2,github,host1}'
alias ssh-keylist="ssh-add -l | sed -e 's;/[^[:space:]]*/;;'"

# SSH_XTERM='env TERM=xterm ssh'
# alias ssh-tetsuji-portbind='$SSH_XTERM tetsuji.jp.portbind -t screen -xR waffle'
# alias ssh-waffle-portbind='$SSH_XTERM waffle.portbind -t screen -xR waffle'
# alias ssh-woody-portbind='$SSH_XTERM woody.portbind -t screen -xR ogata-t'
# alias autossh-tetsuji-portbind='env TERM=xterm AUTOSSH_LOGLEVEL=0 autossh -M 21100 tetsuji.jp.portbind -t "screen -xR waffle"'
# alias autossh-waffle-portbind='env TERM=xterm AUTOSSH_LOGLEVEL=0 autossh -M 21100 waffle.portbind -t "screen -xR waffle"'
# alias autossh-woody-portbind='env TERM=xterm AUTOSSH_LOGLEVEL=0 autossh -M 21200 woody.portbind -t "screen -xR ogata-t"'
#alias killbgssh="ps ux | grep -E 'ssh -[fn]' | awk '{ print $1 }' | xargs --no-run-if-empty kill "

###
### Mac OS X
###
#if type growlnotify >/dev/null 2>&1 ; then
    #alias dialog='growlnotify -s -m '
    #alias notify='read line; growlnotify -m "$line"'
#fi
# airport
if [ "$UNAME" = Darwin ] ; then
    alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport '
    alias airport-info='airport -I'
    alias ssid='airport-info | grep " SSID: " | sed -e "s/.* //"'
    alias ql='qlmanage -p'
    if [ -d '/Applications/Evernote Account Info 1.0.app/' ] ; then
        alias evernote-account-info='/Applications/Evernote\ Account\ Info\ 1.0.app/Contents/MacOS/applet'
    fi
    if type md5 >/dev/null 2>&1 && ! type md5sum >/dev/null 2>&1 ; then
        alias md5sum='md5 -s '
    fi
    alias screen-sharing='open /System/Library/CoreServices/Screen\ Sharing.app/'
    function pbtee {
        cat | pbcopy
        sleep 1
        pbpaste
    }
    function pb-append-quote {
        pbpaste | append-quote | pbcopy
    }
    function pb-remove-quote {
        pbpaste | remove-quote | pbcopy
    }
    alias pb-iconv-change='pbpaste | iconv -c -f UTF-8-MAC -t UTF-8 | pbcopy'
fi

###
### KDE
###
if type dcop >/dev/null 2>&1 ; then
    alias mixer='dcop kmix kmix-mainwindow#1 show'
    alias mute='dcop kmix Mixer0 toggleMasterMute' # arg: "on" or "off"
fi
if type kdialog >/dev/null 2>&1 ; then
    function finish {
        declare status=$? cmd=`history 1 | sed -e 's/^ *[[:digit:]]* *//'`
        kdialog --title "コマンドが終了しました" --msgbox "cmd=${cmd}\nstatus=$status"
    }
fi
#alias ding='test $? -eq 0 && ogg123 -q /usr/share/sounds/KDE_Event_1.ogg || ogg123 -q /usr/share/sounds/KDE_Event_5.ogg'
#alias popup='test $? -eq 0 && kdialog --msgbox 処理が完了しました || kdialog --error エラーコードを受けとりました '
#alias vga-display='xrandr --output VGA --mode 1024x768'
#alias lcd-display='xrandr --output LVDS --mode 1024x768'

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
#	echo "execute TERM=(screen|screen-w|mlterm) environment!"
	return 1
    fi
    declare sock childpid
    for sock in $( find /tmp -type s -name agent.\* -user $USER 2> /dev/null ) ; do
	childpid=$( echo $sock | awk -F. '{ print $2 }' ) # ordinaly "sh"'s pid
	if ps ux | grep $childpid | grep -v grep > /dev/null ; then
	    eval $( ( cat /proc/$childpid/environ ; echo ) | tr "\000" "\n" | egrep ^SSH_AGENT_PID )
	    if [ -z $SSH_AGENT_PID ] ; then
		echo "${FUNCNAME}: error! SSH_AGENT_PID unknonw"
		unset SSH_AGENT_PID
		return 1
	    elif ! ( ps ux | grep $SSH_AGENT_PID | grep -v grep > /dev/null ) ; then
		echo "${FUNCNAME}: error! no process found corresponding SSH_AGENT_PID=$SSH_AGENT_PID"
		unset SSH_AGENT_PID
		return 1
	    fi
	    export SSH_AGENT_PID
	    export SSH_AUTH_SOCK=$sock
	    if ssh-add -l &> /dev/null ; then
		# unsetenv for old (woody) version screen.
#		screen -X unsetenv SSH_AGENT_PID
		if [ $TERM = screen ] || [ $TERM = screen-w ] || [ $TERM = screen.mlterm ] ; then
		    screen -X unsetenv SSH_AUTH_SOCK
		    screen -X setenv SSH_AGENT_PID $SSH_AGENT_PID
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
function cd {
    if [ -z "$1" ] ; then
	# cd 連打で余計な $DIRSTACK を増やさない
	test "$PWD" != "$HOME" && pushd $HOME > /dev/null
    elif [ "x$1" == "x-" ] ; then
	pushd "$OLDPWD" > /dev/null
    elif [ "$1" == "+" ] ; then
	test -z $2 || builtin cd $2
    elif ( echo "$1" | egrep "^\.\.\.+$" > /dev/null ) ; then
	cd $( echo "$1" | perl -ne 'print "../" x ( tr/\./\./ - 1 )' )
    else
	pushd "$1" > /dev/null
    fi
}

# 最近の cd によって移動したディレクトリを選択
function cdhist {
    local newdirnum
    dirs -v | head -n $(( LINES - 3 ))
    read -p "select number: " newdirnum
    if [ -z $newdirnum ] ; then
	echo "gd: Abort." 1>&2
    elif ( echo $newdirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
	cd $( echo ${DIRSTACK[$newdirnum]} | sed -e "s;^~;$HOME;" )
    else
	echo "gd: Wrong." 1>&2
    fi
}

# 現在のディレクトリの中にあるディレクトリを番号指定で移動
function sd {
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
    for d in * ; do test -d "$d" && dirlist[$((++num))]=$d ; done
    for i in $( seq 0 $num ) ; do printf "%3d %s%b\n" $i "$( $opt_f && echo -n "$PWD/" )${dirlist[$i]}" ; done | more
    read -p "select number: " dirnum
    if [ -z $dirnum ] ; then
	echo "sd: Abort." 1>&2
    else
	cd "${dirlist[$dirnum]}"
    fi
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

# Jump cd as shortcut key.
function jcd {
    declare arg dir i
    arg=$1
    if [ -z "$arg" -o "$arg" = "-h" ] ; then
        echo "Usage: $FUNCNAME <directory_alias>"
        return
    elif [ $arg = "-l" ] ; then
        for (( i=0; $i<${#JCD_DIR_MAP[*]}; i=$((i+2)) )) ; do
            key=${JCD_DIR_MAP[$i]}
            value=${JCD_DIR_MAP[$((i+1))]}
            echo "$key => $value"
        done
        return
    fi
    # JCD_DIR_MAP array Example. I define in ~/.bash_secret
#     JCD_DIR_MAP=(
#         dbox ~/Dropbox
#         cvs  ~/cvs
#         etc  /etc
#         );
    #echo "DEBUG: dir arg=$arg #JCD_DIR_MAP=${#JCD_DIR_MAP[*]}"
    for (( i=0; $i<${#JCD_DIR_MAP[*]}; i=$((i+2)) )) ; do
        key=${JCD_DIR_MAP[$i]}
        value=${JCD_DIR_MAP[$((i+1))]}
        #echo "$key => $value"
        if [ "$key" = "$arg" ] ; then
            cd $value
            return
        fi
    done
    echo "directory alias \"$arg\" is not found"
    return 1
}

# chproxy
# http_proxy 環境変数を変更して export する
function chproxy {
    declare i
    declare -a proxy desc
    echo "currently http_proxy is \"$http_proxy\""
    proxy=('http://localhost:8080/' 'http://localhost:3128/')
    desc=('waffle-portbind' 'nv-portbind')
    for i in $( seq 0 $(( ${#proxy[*]} - 1 )) ) ; do
        printf '%3d %8s %s%b\n' $i ${desc[$i]} ${proxy[$i]}
    done
    read -p "select number: " i
    if [ -z $i ] ; then
        echo "chproxy: Abort." 1>&2
    else
        export http_proxy=${proxy[$i]}
    fi
    echo http_proxy=$http_proxy
}

# ssh と tail を使った簡単リモート通知
# ただ使い方が面倒
# http://d.hatena.ne.jp/punitan/20110416/1302928953
# 2011/12/16
function snotifyd {
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
    declare line
    ssh $host env LANG=C tail -q -n 0 -F "$remote_log" \
        | while read line ; do echo "$line" ; growlnotify -s -m "$line" -t $host ; done

    #| perl -e 'system qw/growlnotify -s -m/, $_, '$host' while <STDIN>;'

}

unset ALIASES
unset UNAME

ALIASES_DONE=1
