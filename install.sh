#!/bin/bash
set -eu

function main {
    if ! is-rcm-exist ; then
        echo "rcm is not installed" >&2
        return 1
    fi
    if ! is-codespaces ; then
        echo "this script is only for codespaces" >&2
        return 1
    fi
    backup-home-real-dotfiles
    create-home-dotfiles-dir-symlink
    pwd # for debug
    # Codespaces の場合、シンボリックリンクではなく、-C でコピーを作成する
    #   あと、-f で対話が発生しないようにする
    # Codespaces の場合、~/.dotfiles 自体が揮発的になってしまうことと、
    #   これ自体をシンボリックリンクにしてしまうと、シンボリックリンクが多重となってしまい混乱を生む可能性があるため
    #   -C でコピーを作ることでもろもろ回避しようとしている
    #   ドットファイルに変更があれば、再度 rcup を実行したりすればよい
    # Codespaces では .bashrc .zshrc は温存して、あとで追加する
    env RCRC=./rcrc rcup -v -f -C -x ".bashrc" -x ".zshrc"
}

function is-pwd-dotfiles-root {
    if [ -f "./rcrc" ]; then
        return 0
    else
        return 1
    fi
}

function is-rcm-exist {
    if type "rcup" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function is-codespaces {
    if [ -n "${CODESPACES:-}" ]; then
        return 0
    else
        return 1
    fi
}

function create-home-dotfiles-dir-symlink {
    cloned_dotfiles_dir=$PWD
    ln -v -s $cloned_dotfiles_dir "$HOME/.dotfiles"
}

# 既存のホームディレクトリにドットファイルがある場合、シンボリックでなければバックアップする
function backup-home-real-dotfiles {
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
            echo "skip backup: $dotfile -> $backup_file"
            continue
        fi
        echo "backup: $dotfile -> $backup_file"
        cp -rp "$dotfile" "$backup_file"
    done
}

main "$@"