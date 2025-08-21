#!/usr/bin/env bash

function rse() {
    set -u
	function rse_usage_help() {
		cat << RSE_HELP_EOF >&2
rse: RedStdErr
Run a command with colored/labeled stderr
usage:
    rse command args...               	# stderr in red, stdout normal
    rse -h, --help                    	# print help and exit
    rse -l, --label command args...   	# prefix OUT:/ERR: labels. Can be used when the run command introduces its own colours to stdout/stderr
    rse -q, --quiet-exit              	# suppress [RSE] exit code print
    rse -lq, -ql, --label --quiet-exit 	# combine both
examples:
	# just run a command with rse
	$ rse ls /onefiledir
	onefile

	# Have rse produce a red-colored stderr output
	$ rse ls /doesnotexist
RSE_HELP_EOF
	echo -e "\t\033[1;31mls: cannot access '/doesnotexist': No such file or directory\033[0m" >&2 # coloured in red
	cat << RSE_HELP_EOF >&2
	[RSE] exit code: 2

	# No need to colour stderr, only label it (and stdout)
	$ rse -l ls /doesnotexist
	STDERR: ls: cannot access '/doesnotexist': No such file or directory
	[RSE] exit code: 2

	# Only label stderr and do not print the exit code
	$ rse -q ls /doesnotexist
	STDERR: ls: cannot access '/doesnotexist': No such file or directory
	# no exit code displayed
	$ $? # exit code queried
	bash: 2: command not found

RSE_HELP_EOF
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
