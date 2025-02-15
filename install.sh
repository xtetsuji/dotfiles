#!/bin/bash
set -eu

declare DOTFILES_BACKUP
# DOTFILES_BACKUP が環境変数として定義されていなければ、false にする
: ${DOTFILES_BACKUP:=false}

declare -a INSTALL_DOTFILES_IN_CODESPACES=(
    bash_aliases
    bash_profile
    gitconfig
    gitignore
    inputrc
    tigrc
    vimrc
    zprofile
)

declare -a INSTALL_DEB_PACKAGES_IN_CODESPACES=(
    tig
    bat
    rcm
)

function main {
    if ! is-codespaces ; then
        echo "currently, this script is only for codespaces" >&2
        return 1
    fi
    install-codespaces-fundamental-commands-by-apt
    if ! is-rcm-exist ; then
        echo "rcm is not installed" >&2
        if is-codespaces ; then
            # 取りあえず Ubuntu/Debian 決め打ちで入れてしまう
            sudo apt-get update && sudo apt-get install -y rcm
        else
            echo "please install rcm" >&2
            return 1
        fi
    fi
    if [ ! -f "./rcrc" ] ; then
        echo "./rcrc is not found" >&2
        return 1
    fi
    backup-home-real-dotfiles
    #create-home-dotfiles-dir-symlink
    pwd # for debug
    # Codespaces の場合、シンボリックリンクではなく、-C でコピーを作成する
    #   あと、-f で対話が発生しないようにする
    # Codespaces の場合、~/.dotfiles 自体が揮発的になってしまうことと、
    #   これ自体をシンボリックリンクにしてしまうと、シンボリックリンクが多重となってしまい混乱を生む可能性があるため
    #   -C でコピーを作ることでもろもろ回避しようとしている
    #   ドットファイルに変更があれば、再度 rcup を実行したりすればよい
    # Codespaces では .bashrc .zshrc は温存して、あとで追加する
    # XXX: RCRC 環境変数が意味をなしていない？
    env RCRC=./rcrc rcup -v -f -C -d "$PWD" \
        "${INSTALL_DOTFILES_IN_CODESPACES[@]}"
    # MEMO: bashrc と zshrc は Codespaces のものを採用して、あとで追記する
    # MEMO: bash_completion を読み込むと、ディレクトリ補完で警告が発生するのと
    #       特に現状 Codespaces 上でこれを読まないことで困ることがないので、読み込まないようにする
    append-codespaces-shellrc
}

function is-pwd-dotfiles-root {
    test -f "./rcrc"
}

function is-rcm-exist {
    type "rcup" > /dev/null 2>&1
}

function is-codespaces {
    test -n "${CODESPACES:-}"
}

# 今のディレクトリのシンボリックリンクとして ~/.dotfiles を作成する
# function create-home-dotfiles-dir-symlink {
#     cloned_dotfiles_dir=$PWD
#     ln -v -s $cloned_dotfiles_dir "$HOME/.dotfiles"
# }

# 既存のホームディレクトリにドットファイルがある場合、シンボリックでなければバックアップする
function backup-home-real-dotfiles {
    # DOTFILES_BACKUP 環境変数が true で無ければバックアップしない
    if [ "$DOTFILES_BACKUP" != "true" ] ; then
        echo "backup-home-real-dotfiles: skip backup because \$DOTFILES_BACKUP is not true"
        return 0
    fi
    local loopguard=0
    find "$HOME" \
        -maxdepth 1 \
        -name '.??*' \
        -not -name '.*.bak' \
        -not -name .dotfiles \
        -not -name .local \
        -not -type l \
    | while read dotfile ; do
        backup_file="$dotfile.bak"
        # すでにリアルの ~/.foo がある場合、コピーするものと差分がなければバックアップしない
        if [ -f "$backup_file" ] && cmp -s "$dotfile" "$backup_file" ; then
            echo "skip backup: $dotfile (because \"$backup_file\" is same as \"$dotfile\")"
            continue
        fi
        # カレントディレクトリ（この install.sh があるディレクトリ）に ./foo がない場合、~/.foo はバックアップしない（rcup で書き込みがないので）
        local base_dotfile=$(basename "$dotfile")
        if [ ! -f "./${base_dotfile#.}" ] ; then
            echo "skip backup: $dotfile (because \"./${base_dotfile#.}\" does not exists))"
            continue
        fi
        echo "backup: $dotfile -> $backup_file"
        cp -rp "$dotfile" "$backup_file"
        if (( loopguard++ > 100 )); then
            echo "loopguard" >&2
            break
        fi
    done
}

# Codespaces 追記用に、自分のアカウント名を取得する
function get-my-account {
    if [ -n "${GITHUB_USER:-}" ] ; then
        # シェルインジェクション対策のためチェックする
        if [[ "$GITHUB_USER" =~ ^[a-zA-Z0-9_-]+$ ]] ; then
            echo "@${GITHUB_USER}"
        else
            echo "__myself__"
        fi
    else
        echo "__myself__"
    fi
}

function append-codespaces-bashrc {
    local RCFILE="$HOME/.bashrc"
    local ME=$(get-my-account)
    if [ ! -f "$RCFILE" ] ; then
        return 0
    fi
    if grep -q "$ME" "$RCFILE" ; then
        return 0
    fi
    cat <<'EOF' | sed -e "s/__ME__/$ME/g" >> "$RCFILE"

### for Codespaces by __ME__

source ~/.bash_aliases
source_if_readable ~/.bash_secret
source_if_readable ~/.common_env
if is_interactive_shell ; then
    # source_if_readable ~/.bash_completion # これも念のため重複読み込み対策したい
    # if [ -z "${BASH_COMPLETION_VERSINFO:-}" ] ; then
    #     source_if_readable /etc/bash_completion
    # fi
    function share_history {
        history -a
        history -c
        history -r
    }
    shopt -u histappend
    shopt -s checkwinsize
    PROMPT_COMMAND=share_history
    bind '"\C-g": "git "'
fi
EOF
}

function append-codespaces-zshrc {
    local RCFILE="$HOME/.zshrc"
    local ME=$(get-my-account)
    if [ ! -f "$RCFILE" ] ; then
        return 0
    fi
    if grep -q "$ME" "$RCFILE" ; then
        return 0
    fi
    cat <<'EOF' | sed -e "s/__ME__/$ME/g" >> "$RCFILE"

### for Codespaces by __ME__

source ~/.bash_aliases
source_if_readable ~/.bash_secret
source_if_readable ~/.common_env
if is_interactive_shell ; then
    export HISTSIZE=2000
    export SAVEHIST=100000
    setopt share_history
    setopt hist_ignore_space
    setopt hist_ignore_dups
    setopt hist_no_store
    setopt EXTENDED_HISTORY
    bindkey -e # emacs like keybind
    bindkey -s '^g' 'git '
fi
EOF
}

function append-codespaces-shellrc {
    local login_shell_name=$(basename "$SHELL")
    case "$login_shell_name" in
        bash)
            append-codespaces-bashrc
            ;;
        zsh)
            append-codespaces-zshrc
            ;;
        *)
            echo "unsupported login shell: $login_shell_name" >&2
            ;;
    esac
}

# apt-get が確認できる場合、Codespaces 用の基本的なコマンドをインストールする
function install-codespaces-fundamental-commands-by-apt {
    # apt-get がないなら何もしない
    type apt-get >/dev/null 2>&1 || return 0
    sudo apt-get update && sudo apt-get install -y "${INSTALL_DEB_PACKAGES_IN_CODESPACES[@]}"
}

main "$@"
