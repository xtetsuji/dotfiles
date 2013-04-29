# -*- mode: shell-script ; coding: utf-8 -*-

### relax if it is not interactive.
### (インタラクティブでない場合、何もしない)
test -z "$PS1" && return

### Personal secret settings.
if [ -f ~/.bash_secret ] ; then
    source ~/.bash_secret
fi
### Aliases
if [ -f ~/.bash_aliases ] ; then
    source ~/.bash_aliases
fi
### add at 2011/11/07
if [ -f ~/perl5/perlbrew/etc/bashrc ] ; then
    source ~/perl5/perlbrew/etc/bashrc
fi

case `uname` in
    Darwin) ### Mac OS X
	alias ls='ls -FG' # BSD type "ls"
	# see: http://ascii.jp/elem/000/000/594/594203/
 	alias CharacterPalette='open /System/Library/Input\ Methods/CharacterPalette.app/'
	alias ArchiveUtility='open /System/Library/CoreServices/Archive\ Utility.app/'
	alias iPhoneSimulator='open /Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	;;
    Linux)
	alias ls='ls --color=auto'
	;;
esac

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

### Prompt
case "$TERM" in
    xterm-color) color_prompt=yes;;
    xterm-256color) color_prompt=yes;;
    screen) color_prompt=yes;; # Is modern screen OK!?
esac
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
if [ "$color_prompt" = yes ] ; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
unset color_prompt

### add at 2013/02/24
export GROWL_ANY_DEFAULT_BACKEND=CocoaGrowl
export GROWL_ANY_DEBUG=0
# I like CocoaGrowl than MacGrowl.

### proxy
export http_proxy=http://localhost:8080/
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
export HTTPS_PROXY=$http_proxy
export FTP_PROXY=$http_proxy

### history
# see: http://tukaikta.blog135.fc2.com/blog-entry-187.html
function share_history {
    history -a
    history -c
    history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
shopt -s checkwinsize
### add at 2012/07/01
# http://blog.withsin.net/2010/12/29/bash%E3%81%AEhistcontrol%E5%A4%89%E6%95%B0/
# ignoredups：連続した同一コマンドの履歴を1回に
# ignorespace：空白から始まるコマンドを履歴に残さない
# ignoreboth:上記の両方を設定
export HISTCONTROL=ignoreboth

### bash_completion
if type brew >/dev/null 2>&1 && [ -f $(brew --prefix)/etc/bash_completion ] ; then
    # Mac homebrew
    source $(brew --prefix)/etc/bash_completion
elif [ -f /etc/bash_completion ] ; then
    # Debian
    source /etc/bash_completion
fi

### add at 2012/03/19
if type lv >/dev/null 2>&1 ; then
    export PAGER=lv
fi
if type vi >/dev/null 2>&1 ; then
    export EDITOR=vi
fi

if ! type lv &>/dev/null && type less &>/dev/null ; then
    alias lv=less
    export LESS=-M
    if type /usr/bin/lesspipe &>/dev/null ; then
        export LESSOPEN="| /usr/bin/lesspipe '%s'"
        export LESSCLOSE="/usr/bin/lesspipe '%s' '%s'"
    fi
fi

# avoid Ctrl-D logout.
IGNOREEOF=3

### add at 2012/04/25
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
export AWS_RDS_HOME=$HOME/tmp/RDSCli-1.6.001
export AWS_CREDENTIAL_FILE=$AWS_RDS_HOME/credential-file-path
