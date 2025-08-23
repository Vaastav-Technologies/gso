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
		echo -e "    rse -m command args...             # output formatted in markdown (HTML spans) inside <pre>" >&2
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
		echo -e "    <pre>" >&2
		echo -e "    <span style=\"color:red\">ls: cannot access '/doesnotexist': No such file or directory</span>" >&2
		echo -e "    <span style=\"color:red\">[RSE]</span> exit code: 2" >&2
		echo -e "    </pre>" >&2
        echo -e "env-vars:" >&2
        echo -e "   Environment variables can be used to set the shell mode at the start. Following environment variables mimic the short CLI options:" >&2
        echo -e "   RSE_NOEXIT  -> -q" >&2
        echo -e "   RSE_LBL     -> -l" >&2
        echo -e "   RSE_MD      -> -m" >&2
	}

    local env_label=false
    local env_md=false
    local sh_label=false
    local sh_md=false
    local label=false
    local quiet_exit=false
    local markdown=false

    [[ -v RSE_LBL && -v RSE_MD ]] && echo "rse: RSE_LBL and RSE_MD env-vars cannot be used together. Unset one or the other." >&2 && return 2
    [[ -v RSE_LBL ]] && env_label=true
    [[ -v RSE_MD ]] && env_md=true
    [[ -v RSE_NOEXIT ]] && quiet_exit=true

    # Reset OPTIND for getopts
    OPTIND=1

    # Parse short options (clusters supported)
    while getopts ":hlqm" opt; do
        case $opt in
            h)  rse_usage_help
                return 0 ;;
            l) sh_label=true ;;
            q) quiet_exit=true ;;
            m) sh_md=true ;;
            \?) echo "rse: unknown option -$OPTARG" >&2; return 2 ;;
        esac
    done
    shift $((OPTIND -1))

    # Mutually exclusive check
    if $sh_label && $sh_md; then
        echo "rse: -l and -m cannot be used together" >&2
        return 2
    fi

    # Resolve mode: CLI flags override env-vars
    $sh_label || $env_label && label=true
    $sh_md || $env_md && markdown=true

    local status=0

    if $markdown; then
        # Capture command output and print in proper order with <pre> wrapper
        echo "<pre>" >&2
        ("$@" \
            > >(sed 's|.*|<span style=\"color:green\">&</span>|') \
            2> >(sed 's|.*|<span style=\"color:red\">&</span>|' >&2))
        wait
        status=$?
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
                # Base case: color stdout green
                ( "$@" | sed -e "s/^.*$/$(echo -en '\033[32;1m')&$(echo -en '\033[0m')/" )
                # (
                #     "$@" \
                #     1> >(sed -e "s/^.*$/$(echo -en '\033[32;1m')&$(echo -en '\033[0m')/") \
                #     2> >(sed -e "s/^.*$/$(echo -en '\033[31;1m')&$(echo -en '\033[0m')/" >&2)
                # )
            fi
        )
        status=$?

        if ! $quiet_exit; then
            echo -e "\033[31;1m[RSE]\033[0m exit code: $status" >&2
        fi
    fi

    return $status
}
