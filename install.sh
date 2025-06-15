#!/bin/bash
set -eu

declare UNAME="$(uname)"
declare DOTFILES_BACKUP
# DOTFILES_BACKUP が環境変数として定義されていなければ、false にする
: ${DOTFILES_BACKUP:=false}

declare DRY_RUN
# DRY_RUN が環境変数として定義されていなければ、false にする
: ${DRY_RUN:=false}

declare -a INSTALL_DOTFILES_IN_CODESPACES=(
    bash_aliases
    bash_profile
    common_env
    gitconfig
    gitignore
    inputrc
    path_functions
    tigrc
    vimrc
    zprofile
)

# 実験でいくつかだけ自動インストール
declare -a INSTALL_DOTFILES_IN_MACOS=(
    bash_aliases
    common_env
    gitconfig
    gitignore
    nanorc
    path_functions
    tigrc
    vimrc
)

declare -a INSTALL_DEB_PACKAGES_IN_CODESPACES=(
    tig
    bat
    rcm
)

function main {
    if is-codespaces ; then
        install-codespaces-fundamental-commands-by-apt
        setup-bat || true
        if ! is-rcm-exist ; then
            echo "rcm is not installed" >&2
            # 取りあえず Ubuntu/Debian 決め打ちで入れてしまう
            sudo apt-get update && sudo apt-get install -y rcm
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
    elif is-macos ; then
        dispatch-macos
    else
        echo "currently, this script is only for codespaces or macOS" >&2
        return 1
    fi
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

function is-macos {
    test "$UNAME" = "Darwin"
}

function dispatch-macos {
    backup-home-real-dotfiles
    pwd # for debug
    # macOS の場合、シンボリックリンクで実装する
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY-RUN] Would execute: env RCRC=./rcrc rcup -v -d '$PWD' ${INSTALL_DOTFILES_IN_MACOS[*]}"
        echo "[DRY-RUN] Files that would be linked:"
        for file in "${INSTALL_DOTFILES_IN_MACOS[@]}"; do
            if [ -f "./$file" ]; then
                echo "  $PWD/$file -> $HOME/.$file"
            else
                echo "  [WARNING] Source file not found: ./$file"
            fi
        done
    else
        env RCRC=./rcrc rcup -v -d "$PWD" \
            "${INSTALL_DOTFILES_IN_MACOS[@]}"
    fi
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

# RCFILE チェック
function check-rcfile {
    local RCFILE="$1"
    local ME="$2"
    if [ ! -f "$RCFILE" ] ; then
        echo "RCFILE not found: $RCFILE" >&2
        return 1
    fi
    if grep -q "$ME" "$RCFILE" ; then
        echo "RCFILE already has '$ME': $RCFILE" >&2
        return 1
    fi
}

# Codespaces の .bashrc に自分のコンパクトな定義を追記する
function append-codespaces-bashrc {
    local RCFILE="$HOME/.bashrc"
    local ME=$(get-my-account)
    if ! check-rcfile "$RCFILE" "$ME" ; then
        return 0
    fi
    cat <<'EOF' | sed -e "s/__ME__/$ME/g" >> "$RCFILE"

###
### for Codespaces by __ME__
###

source ~/.path_functions
source ~/.common_env
source ~/.bash_aliases
source_if_readable ~/.bash_secret
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

# For Cursor + SSH Codespaces connection setting. This emulates the behavior of VSCode's initial connection
# by automatically changing to the repository directory when connected.
if [ "$CODESPACES" = "true" ] ; then
    if [ "$PWD" = "$HOME" ] && [ -d "/workspaces/$RepositoryName" ] ; then
        cd "/workspaces/$RepositoryName"
    fi
fi
EOF
}

function append-codespaces-zshrc {
    local RCFILE="$HOME/.zshrc"
    local ME=$(get-my-account)
    if ! check-rcfile "$RCFILE" "$ME" ; then
        return 0
    fi
    cat <<'EOF' | sed -e "s/__ME__/$ME/g" >> "$RCFILE"

###
### for Codespaces by __ME__
###

source ~/.path_functions
source ~/.common_env
source ~/.bash_aliases
source_if_readable ~/.bash_secret
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

# For Cursor + SSH Codespaces connection setting. This emulates the behavior of VSCode's initial connection
# by automatically changing to the repository directory when connected.
if [ "$CODESPACES" = "true" ] ; then
    if [ "$PWD" = "$HOME" ] && [ -d "/workspaces/$RepositoryName" ] ; then
        cd "/workspaces/$RepositoryName"
    fi
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

# bat パッケージを入れた後、batcat コマンドを bat コマンドとして実行できるようにする
function setup-bat {
    if ! type batcat > /dev/null 2>&1 ; then
        echo "batcat is not installed" >&2
        return 1
    fi
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
}

main "$@"
