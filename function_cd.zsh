is_current_zsh && \
function cd {
    local arg="$1" dir subcommand
    if [ "${arg:0:1}" = ":" ] ; then
        subcommand="${arg#:}"
        shift || true
        case "$subcommand" in
            planter)
                dir="$(planter peco)"
                ;;
            repo)
                dir=$(cd-plugin-repo | peco --select-1 --query="${1:-}")
                ;;
            isearch)
                dir="$(mdfind 'kMDItemContentType == "public.folder"' | peco --select-1 )"
                ;;
            isearch-home)
                dir="$(mdfind -onlyin $HOME 'kMDItemContentType == "public.folder"' | peco --select-1 )"
                ;;
            *)
                echo "subcommand \"$subcommand\" is not found"
                return 1
                ;;
        esac
        if [ -z "$dir" ] ; then
            echo "select stop"
            return
        fi
    else
        dir="$arg"
    fi
    if [ -z "$dir" ] ; then
        builtin cd
    else
        builtin cd "$dir"
    fi
}
