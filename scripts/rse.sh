#!/usr/bin/env bash

function rse() {
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
    local markdown=false

    # Reset OPTIND for getopts
    OPTIND=1

    # Parse short options (clusters supported)
    while getopts ":hlqm" opt; do
        case $opt in
            h)  rse_usage_help
                return 0 ;;
            l) label=true ;;
            q) quiet_exit=true ;;
            m) markdown=true ;;
            \?) echo "rse: unknown option -$OPTARG" >&2; return 2 ;;
        esac
    done
    shift $((OPTIND -1))

    # Mutually exclusive check
    if $label && $markdown; then
        echo "rse: -l and -m cannot be used together" >&2
        return 2
    fi

    local status=0

    if $markdown; then
        # Emit everything to a single stream (stderr) so <pre> wraps consistently
        echo "<pre>" >&2
        (
            stdbuf -o0 -e0 "$@" \
            > >(sed 's|.*|<span>&</span>|' >&2) \
            2> >(sed 's|.*|<span style="color:red">&</span>|' >&2)
        )
        status=$?
        wait
        if ! $quiet_exit; then
            echo "<span style=\"color:red\">[RSE]</span> exit code: $status" >&2
        fi
        echo "</pre>" >&2

    else
        (
            if $label; then
                # Label mode: keep streams separate; stdout stays stdout, stderr stays stderr
                stdbuf -oL -eL "$@" \
                > >(sed 's/^/OUT: /') \
                2> >(sed 's/^/ERR: /' >&2)
            else
                # Base case: color stderr red with descriptor swap to preserve stderr
                ( "$@" 3>&1 1>&2 2>&3 \
                | sed -e "s/^.*$/$(echo -en '\033[31;1m')&$(echo -en '\033[0m')/" >&2 ) 3>&1 1>&2 2>&3 \
                | cat
            fi
        )
        status=$?

        if ! $quiet_exit; then
            echo -e "\033[31;1m[RSE]\033[0m exit code: $status" >&2
        fi
    fi

    return $status
}
