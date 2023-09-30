#!/bin/bash
set -eu

function main {
    backup-dotfiles
    pwd # for debug
    env RCRC=./rcrc rcup
}

function is-codespaces {
    if [ -n "${CODESPACES:-}" ]; then
        return 0
    else
        return 1
    fi
}

# 既存のホームディレクトリにドットファイルがある場合、シンボリックでなければバックアップする
function backup-dotfiles {
  if [ -e "$HOME/$1" -a ! -L "$HOME/$1" ]; then
    echo "backup $HOME/$1"
    mv "$HOME/$1" "$HOME/$1.bak"
  fi
}

main "$@"