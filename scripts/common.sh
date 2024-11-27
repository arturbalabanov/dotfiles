#!/bin/bash

# TODO: Some duplication with ~/.zshrc


# Usage: confirm [<prompt-message>] [error-message]
function confirm() {
    prompt="${1:-confirm?}"
    error_msg="${2:-aborted}"

    read -p "$prompt [y/N] " -n 1 -r
    echo    # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "$error_msg"
    fi
}

# Usage: error [exit-code] <message...>
function error() {
    # if the first argument is an integer, it is the exit code

    if [[ "$1" =~ ^[0-9]+$ ]]; then
        exit_code=$1
        shift
    else
        exit_code=1
    fi

    echo -n "error: " >&2

    while [[ "$#" -gt 0 ]]; do
        echo "$1" >&2
        shift
    done

    exit "$exit_code"
}

function cmd_name() {
    basename "$0"
}

# Usage: catch <stdout-var> <stderr-var> <command> [args...]
# ref: https://stackoverflow.com/a/41069638
function catch() {
    eval "$({
        __2="$(
            { __1="$("${@:3}")"; } 2>&1
            ret=$?
            printf '%q=%q\n' "$1" "$__1" >&2
            exit $ret
        )"

        ret="$?"

        printf '%s=%q\n' "$2" "$__2" >&2
        printf '( exit %q )' "$ret" >&2
    } 2>&1 )";
}

# Usage: dependancy <command-name>
function dependancy {
	command_name=$1

	if ! type "$command_name" >/dev/null 2>&1; then
		echo "'$command_name' required but not found" >&2
		exit 1
	fi
} 

# Usage: get_extension <file-path>
function get_extension {
    file=$(basename -- "$1")
    echo "${file##*.}"
}
