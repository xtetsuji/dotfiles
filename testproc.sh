#!/bin/bash
# testproc.sh - dotfiles install.sh test script
set -eu

TESTHOME=/home/testhome
TESTUSER=$USER

function usage {
    echo "Usage: $0"
    echo "  list"
    echo "  install"
    echo "  mkdir"
    echo "  move"
    echo "  bash"
    echo "  zsh"
    exit 1
}

function mkdir-testhome {
    sudo mkdir -vp $TESTHOME
    sudo chown -v $TESTUSER:$TESTUSER $TESTHOME
    cp -vp ~/.bashrc ~/.zshrc $TESTHOME/
}

function list-testhome {
    ls -al $TESTHOME
}

function move-testhome {
    sudo mv -v $TESTHOME $TESTHOME.$(date +%Y%m%d%H%M%S)
}

function install-dotfiles {
    env HOME=$TESTHOME ./install.sh
}

function bash-login {
    echo "now SHLVL=$SHLVL"
    echo "test login on $TESTHOME by bash"
    exec env HOME=$TESTHOME bash -l
}

function zsh-login {
    echo "now SHLVL=$SHLVL"
    echo "test login on $TESTHOME by zsh"
    exec env HOME=$TESTHOME zsh -l
}

function main {
    local subcommand="${1:-}"
    case "$subcommand" in
        "mkdir" )
            mkdir-testhome
            ;;
        "list" )
            list-testhome
            ;;
        "move" )
            move-testhome
            ;;
        "install" )
            install-dotfiles
            ;;
        "bash" )
            bash-login
            ;;
        "zsh" )
            zsh-login
            ;;
        * )
            usage
            ;;
    esac
}

main "$@"
