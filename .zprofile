# Don't load if it's been already loaded (e.g. tmuxp loads this for every tmux pane it seems)
if [[ $ZPROFILE_LOADED ]]; then
    return
fi

export ZPROFILE_LOADED=1

# Setup PATH and OS-specific setup {{{
# NOTE: THE ORDER IN THIS SECTION MATTERS!!!

export PATH="$PATH:$HOME/.local/bin:$HOME/node_modules/.bin"
export MANPATH="$MANPATH:$HOME/.local/man"

has_brew=$(
    [[ \
        $OSTYPE == 'darwin'* \
        && $(uname -m) == "arm64" \
        && -d "/opt/homebrew" \
    ]] && echo "1" || echo ""
)

if [[ $has_brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if type pyenv > /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    if [[ $has_brew ]]; then
        alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
    fi
fi

if type go > /dev/null; then
    export GOPATH=$(go env GOPATH)
    export PATH=$PATH:$GOPATH/bin
fi

if [[ $OSTYPE == 'linux'* ]]; then
    alias open='xdg-open'
fi
# }}}
# Other env vars {{{
if [ -f ~/.host_alias ]; then
	export _HOST_ALIAS=$(cat ~/.host_alias)
fi

if type nvim > /dev/null; then
    export EDITOR="nvim"
elif type vim > /dev/null; then
    export EDITOR="vim"
else
    export EDITOR="nvim"
fi

if [[ $OSTYPE == 'linux'* ]]; then
    export BROWSER="google-chrome-stable"
fi

if type pipenv > /dev/null; then
    export PIPENV_VENV_IN_PROJECT=1
fi
# }}}

# if [[ $has_brew ]]; then
#     brew_nvm_path="$(brew --prefix)/opt/nvm"
#
#     if [[ -d $brew_nvm_path ]]; then
#         export NVM_DIR="$HOME/.nvm"
#
#         if [[ -f "$brew_nvm_path/nvm.sh" ]]; then
#             source "$brew_nvm_path/nvm.sh"
#         fi
#
#         if [[ -f "$brew_nvm_path/etc/bash_completion.d/nvm" ]]; then
#             source "$brew_nvm_path/etc/bash_completion.d/nvm"
#         fi
#     fi
# fi

# export PATH="/Users/artur/.asdf/shims:/opt/homebrew/opt/asdf/libexec/bin:/Users/artur/.pyenv/shims:/Users/artur/.pyenv/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware Fusion.app/Contents/Public:/Applications/Wireshark.app/Contents/MacOS:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Users/artur/.pyenv/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Applications/kitty.app/Contents/MacOS:/Users/artur/.local/bin:/Users/artur/node_modules/.bin:/Users/artur/go/bin:/Users/artur/.local/bin:/Users/artur/node_modules/.bin:/Users/artur/go/bin:/Users/artur/.vector/bin"
