function _ps2 {
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
    # MEMO: zsh compatible, read `-p` option is different as printing prompt.
    #read -p "Choice [kill|kill -*|SIG***|pbcopy]: " choice
    echo -n "Choice [kill|kill -*|SIG***|pbcopy]: "
    read choice
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

_ps2 "$@"
