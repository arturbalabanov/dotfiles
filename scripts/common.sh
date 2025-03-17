#!/bin/bash

# TODO: Some duplication with ~/.zshrc


# Usage: confirm [<prompt-message>] [default=Y] [error-message] 
function confirm() {
    prompt="${1:-confirm?}"
    default="${2:-N}"
    error_msg="${3:-aborted}"

    if [[ "$default" =~ ^[Yy]$ ]]; then
        read -p "$prompt [Y/n] " -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            error "$error_msg"
        fi
    elif [[ "$default" =~ ^[Nn]$ ]]; then
        read -p "$prompt [y/N] " -n 1 -r
        echo    # move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "$error_msg"
        fi
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

# Usage: op_get_credential "<item_name>" [field_name=credential]
# ref: https://developer.1password.com/docs/cli/reference/
# 
# Run "op item list --vault ..." to get the list of all items in a given vault
function op_get_credential {
    if [[ "$#" -eq 0 ]]; then
		error "at least 1 argument is required to run $0"
	fi

    item_name="$1"
    field_name="${2:-credential}"

    op item get "$item_name" --fields label="$field_name" --reveal
}

