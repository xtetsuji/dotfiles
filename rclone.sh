#!/bin/bash
set -eu

function usage {
    cat <<EOF
Usage: $0 [setup|mount|unmount|lsmnt|env]

    setup:
        setup rclone config file to ~/.config/rclone/rclone.conf
        from RCLONE_CONF_* environment variables.
    mount:
        mount rclone remotes to /mnt/<remote> directory.
        remotes are listed by \`rclone listremotes\` command.
    unmount:
        unmount rclone remotes from /mnt/<remote> directory.
    lsmnt:
        list mounted rclone remotes.
    env:
        list RCLONE_CONF_* environment variables.
EOF
}

function main {
    local subcommand="${1:-}"
    case "$subcommand" in
        setup)
            dispatch-setup "$@"
            ;;
        mount)
            dispatch-mount "$@"
            ;;
        unmount)
            dispatch-unmount "$@"
            ;;
        env)
            dispatch-env "$@"
            ;;
        lsmnt)
            dispatch-lsmnt "$@"
            ;;
        *)
            usage
            return 1
            ;;
    esac
}

function dispatch-setup {
    declare -a rclone_conf_keys=($(env | grep ^RCLONE_CONF_ | sed -e 's/=.*//'))
    if [[ ${#rclone_conf_keys[@]} == 0 ]]; then
        echo "RCLONE_CONF_* is not defined" >&2
        return 1
    fi
    setup-config-place
    for key in "${rclone_conf_keys[@]}"; do
        # local conf_name="$(echo "$key" | sed -e 's/^RCLONE_CONF_//')"
        local value="${!key}"
        echo "$value" >> ~/.config/rclone/rclone.conf
    done
}

function dispatch-mount {
    for remote in $(remotes); do
        if [ ! -d /mnt/$remote ]; then
            sudo mkdir -vp /mnt/$remote
            sudo chown -v $USER:$USER /mnt/$remote
        fi
        echo "rclone mount $remote: /mnt/$remote"
        rclone mount $remote: /mnt/$remote &
    done
}

function dispatch-unmount {
    for remote in $(remotes); do
        sudo umount -v /mnt/$remote
    done
}

function dispatch-lsmnt {
    mount | grep rclone
}

function dispatch-env {
    env | grep ^RCLONE_CONF_
}

function remotes {
    rclone listremotes | sed -e 's/:$//'
}

function setup-config-place {
    mkdir -v ~/.config/rclone
    if [ -f ~/.config/rclone/rclone.conf ]; then
        echo "already exists: ~/.config/rclone/rclone.conf. move to /tmp/." >&2
        mv -v ~/.config/rclone/rclone.conf /tmp/rclone.conf.$(date +%Y%m%d%H%M%S)
    fi
    touch ~/.config/rclone/rclone.conf
}

main "$@"
