# previous cd at 2005/03/22 (original idea)
# enahnced cd at 2019/03/31 (following)
is_current_bash && \
function cd {
    #set -x
    local arg="$1" subcommand result rc
    if [ -z "$arg" ] ; then ### home directory
        # cd 連打で余計な $DIRSTACK を増やさない
        test "$PWD" = "$HOME" || pushd $HOME >/dev/null
        return
    elif [ "${arg:0:1}" = ":" ] ; then ### command mode
        # コロンコマンドは xtcd.sh にディスパッチする
        subcommand="${arg#:}" ; shift
        case "$subcommand" in
            history)
                result="$( dirs -v | xtcd.sh :history "$@" )"
                ;;
            clear)
                dirs -c ; return
                ;;
            help|subcommands)
                xtcd.sh :$subcommand "$@"
                return
                ;;
            up|down|drop|which|pwdsed|repo|stdin|mdfind|bookmark)
                if [ $subcommand = bookmark -a $# -gt 0 ] ; then
                    # $() 中だと $EDITOR が起動できないので冒頭で処理している
                    xtcd.sh :bookmark "$@"
                    return
                fi
                result="$( xtcd.sh :$subcommand "$@" )"
                rc=$?
                if [ $rc = 100 ] ; then
                    # 終了ステータス100の場合、受け取った出力を流して、ここの（呼び出し元）で穏当に終了する
                    echo "$result"
                    return 0
                elif [ $rc -gt 0 ] ; then
                    echo "xtcd.sh returns error code" >&2
                    return 1
                fi
                ;;
            *)
                echo "unknown command :$subcommand" >&2
                return 1
                ;;
        esac
        if [ "${result:0:1}" = "~" ] ; then
            result=$HOME${result#"~"}
        fi
        if [ -f "$result" ] ; then
            result="${result%/*}"
        fi
    else
        result="$arg"
    fi
    if [ -n "$result" ] ; then
        pushd "$result" >/dev/null
        if [ -n "$subcommand" -a "$subcommand" = drop ] ; then
            cd :drop
        fi
    fi
    #set +x
}

