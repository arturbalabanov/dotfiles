eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -f ~/.host_alias ]; then
	export _HOST_ALIAS=$(cat ~/.host_alias)
fi
