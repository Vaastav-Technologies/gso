#!/usr/bin/env bash

function rse() {
    set -u
	function rse_usage_help() {
		echo -e "rse: RedStdErr" >&2
		echo -e "Run a command with colored/labeled/markdown stderr" >&2
		echo -e "usage:" >&2
		echo -e "    rse command args...                # stderr in red, stdout normal" >&2
		echo -e "    rse -h                             # print help and exit" >&2
		echo -e "    rse -l command args...             # prefix OUT:/ERR: labels, useful when colorised output is not desired but still output differentiation is needed." >&2
		echo -e "    rse -q                             # suppress \033[31;1m[RSE]\033[0m exit code print" >&2
		echo -e "    rse -m command args...             # output formatted in markdown (HTML spans)" >&2
		echo -e "" >&2
		echo -e "options:" >&2
		echo -e "    -l and -m are mutually exclusive" >&2
		echo -e "" >&2
		echo -e "examples:" >&2
		echo -e "    $ rse ls /doesnotexist" >&2
		echo -e "    \033[31;1mls: cannot access '/doesnotexist': No such file or directory\033[0m" >&2
		echo -e "    \033[31;1m[RSE]\033[0m exit code: 2" >&2
		echo -e "" >&2
		echo -e "    $ rse -l ls /doesnotexist" >&2
		echo -e "    ERR: ls: cannot access '/doesnotexist': No such file or directory" >&2
		echo -e "    \033[31;1m[RSE]\033[0m exit code: 2" >&2
		echo -e "" >&2
		echo -e "    $ rse -m ls /doesnotexist" >&2
		echo -e "    <span style=\"color:red\">ls: cannot access '/doesnotexist': No such file or directory</span><br>" >&2
		echo -e "    <span style=\"color:red\">[RSE]</span> exit code: 2" >&2
	}

    local label=false
    local quiet_exit=false

    # First, translate long options into short ones
    local args=()
    for arg in "$@"; do
        case "$arg" in
            --help) args+=(-h) ;;
            --label) args+=(-l) ;;
            --quiet-exit) args+=(-q) ;;
            --) args+=(--) ;;   # end of options
            --*) echo "rse: unknown option $arg" >&2; return 2 ;;
            *) args+=("$arg") ;;
        esac
    done

    # Reset OPTIND for getopts
    OPTIND=1

    # Parse short options (including clusters like -lq)
    while getopts ":hlq" opt "${args[@]}"; do
        case $opt in
            h)	rse_usage_help
                return 0
                ;;
            l) label=true ;;
            q) quiet_exit=true ;;
            \?)
                echo "rse: unknown option -$OPTARG" >&2
                return 2
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Run command in subshell so we can capture exit code
    (
        if $label; then
            "$@" \
                > >(sed 's/^/OUT: /') \
                2> >(sed 's/^/ERR: /' >&2)
        else
            "$@" \
                > >(cat) \
                2> >(sed -e "s/^\(.*\)$/$(echo -en '\033[31;1m')\1$(echo -en '\033[0m')/" >&2)
        fi
    )
    local status=$?

    if ! $quiet_exit; then
		wait
        echo -e "\033[1;31m[RSE]\033[0m exit code: $status" >&2
    fi

    return $status
}
