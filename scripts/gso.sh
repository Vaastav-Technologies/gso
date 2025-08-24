#!/usr/bin/env bash

function gso() {
	function gso_usage_help() {
		echo -e "gso: GreenStdOut" >&2
		echo -e "Run a command with colored/labeled/markdown stdout." >&2
		echo -e "This will distinguish stdout form stderr." >&2
		echo -e "usage:" >&2
		echo -e "    gso command args...                # stdout in green, stderr normal" >&2
		echo -e "    gso -h                             # print help and exit" >&2
		echo -e "    gso -l command args...             # prefix OUT: labels per line for stdout, useful when colourised output is not desired but still output differentiation is needed." >&2
		echo -e "    gso -q                             # suppress \033[31;1m[GSO]\033[0m exit code print" >&2
		echo -e "    gso -m command args...             # output formatted in markdown (HTML spans) inside <pre>" >&2
		echo -e "" >&2
		echo -e "options:" >&2
		echo -e "    -l and -m are mutually exclusive" >&2
		echo -e "" >&2
		echo -e "examples:" >&2
		echo -e "    $ gso ls . /doesnotexist" >&2
		echo -e "    \033[32;1mcurrent directory contents\033[0m" >&2
		echo -e "    ls: cannot access '/doesnotexist': No such file or directory\033[0m" >&2
		echo -e "    \033[31;1m[GSO]\033[0m exit code: 2" >&2
		echo -e "" >&2
		echo -e "    $ gso -l ls . /doesnotexist" >&2
		echo -e "    OUT: current directory contents" >&2
		echo -e "    ls: cannot access '/doesnotexist': No such file or directory" >&2
		echo -e "    \033[31;1m[GSO]\033[0m exit code: 2" >&2
		echo -e "" >&2
		echo -e "    $ gso -m ls . /doesnotexist" >&2
		echo -e "    <pre>" >&2
		echo -e "    <span style=\"color:green\">current directory contents</span>" >&2
		echo -e "    ls: cannot access '/doesnotexist': No such file or directory" >&2
		echo -e "    <span style=\"color:red\">[GSO]</span> exit code: 2" >&2
		echo -e "    </pre>" >&2
    echo -e "env-vars:" >&2
    echo -e "   Environment variables can be used to set the shell mode at the start. Following environment variables mimic the short CLI options:" >&2
    echo -e "   GSO_NOEXIT  -> -q" >&2
    echo -e "   GSO_LBL     -> -l" >&2
    echo -e "   GSO_MD      -> -m" >&2
    echo -e "Note: CLI options take priority over env-vars." >&2
	}

  local env_label=false
  local env_md=false
  local sh_label=false
  local sh_md=false
  local label=false
  local quiet_exit=false
  local markdown=false

  [[ -v GSO_LBL && -v GSO_MD ]] && echo "gso: GSO_LBL and GSO_MD env-vars cannot be used together. Unset one or the other." >&2 && return 2
  [[ -v GSO_LBL ]] && env_label=true
  [[ -v GSO_MD ]] && env_md=true
  [[ -v GSO_NOEXIT ]] && quiet_exit=true

  # Reset OPTIND for getopts
  OPTIND=1

  # Pagso short options (clusters supported)
  while getopts ":hlqm" opt; do
    case $opt in
      h) gso_usage_help
         return 0 ;;
      l) sh_label=true ;;
      q) quiet_exit=true ;;
      m) sh_md=true ;;
      \?) echo "gso: unknown option -$OPTARG" >&2; return 2 ;;
    esac
  done
  shift $((OPTIND -1))

  # Mutually exclusive check
  if $sh_label && $sh_md; then
    echo "gso: -l and -m cannot be used together" >&2
    return 2
  fi

  # Resolve mode: CLI flags override env-vars
  if $env_label; then 
    label=true
    markdown=false
  elif $env_md; then
    label=false
    markdown=true
  fi

  if $sh_label; then
    label=true
    markdown=false
  elif $sh_md; then
    label=false
    markdown=true
  fi

  local status=0

  if $markdown; then
    echo "<pre>" >&2
    "$@" | sed 's|.*|<span style=\"color:green\">&</span>|'
    status=${PIPESTATUS[0]}
    if ! $quiet_exit; then
      echo "<span></span>" >&2
      echo "<span style=\"color:red\">[GSO]</span> exit code: $status" >&2
    fi
    echo "</pre>" >&2

  else
    if $label; then
      # Label mode: keep streams separate; stdout stays stdout, stderr stays stderr
      "$@" | sed 's/^/OUT: /'
    else
      # Base case: color stdout green
      "$@" | sed -e "s/^.*$/$(echo -en '\033[32;1m')&$(echo -en '\033[0m')/"
    fi
    status=${PIPESTATUS[0]}

    if ! $quiet_exit; then
      echo -e "\033[31;1m[GSO]\033[0m exit code: $status" >&2
    fi
  fi

  return $status
}
