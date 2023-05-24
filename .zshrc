# OS Detection {{{
# From: https://stackoverflow.com/a/27776822
case "$(uname -sr)" in
    Darwin*)
        os="macos"
        ;;

    Linux*Microsoft*)
        os='wsl'  # Windows Subsystem for Linux
        ;;

    Linux*)
        os='linux'
        ;;

    CYGWIN*|MINGW*|MINGW32*|MSYS*)
        os="windows"
        ;;
esac
# }}}
# Oh my ZSH {{{
export ZSH=$HOME/.oh-my-zsh

if type starship > /dev/null; then
    eval "$(starship init zsh)"
else
    ZSH_THEME="artur" 
fi

export DISABLE_AUTO_UPDATE="true"
export DISABLE_AUTO_TITLE="true"
export HIST_STAMPS="dd.mm.yyyy"

plugins=(zsh-syntax-highlighting vi-mode zle-vi-visual pdm)
source $ZSH/oh-my-zsh.sh
# }}}
# Terminal wizardry {{{
if type dircolors > /dev/null; then
    eval $(dircolors ~/.dircolors)
fi

# Stupid Ctrl-S!
stty -ixon

# man page colors
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking 
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold 
export LESS_TERMCAP_me=$'\E[0m'           # end mode 
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode 
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box 
export LESS_TERMCAP_ue=$'\E[0m'           # end underline 
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

export LESS="$LESS -x4"  # less uses 4 space tab witdh
# }}}
# VIM Mode {{{
function _set_cursor_shape {
    shape="$1"

    case $shape in
        block)
            echo -ne '\e[2 q'
            ;;
        block_blink)
            echo -ne '\e[1 q'
            ;;
        underscore)
            echo -ne '\e[4 q'
            ;;
        underscore_blink)
            echo -ne '\e[3 q'
            ;;
        line)
            echo -ne '\e[6 q'
            ;;
        line_blink)
            echo -ne '\e[6 q'
            ;;
        *)
            return 1
            ;;
    esac
}

function zle-keymap-select zle-line-init {
    case $KEYMAP in
        vicmd)
            _set_cursor_shape "block"
            ;;
        viins||main)
            _set_cursor_shape "line"
            ;;
        vivis)
            _set_cursor_shape "block"
            ;;
    esac

    zle reset-prompt
    zle -R
}

function zle-line-finish {
    _set_cursor_shape "block"
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-finish

# Vimode keybindings
bindkey -M viins 'jj' vi-cmd-mode

bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line

bindkey -M vicmd 'L' end-of-line

tmux-select-pane-up () {
    tmux select-pane -U
}
zle -N tmux-select-pane-up
bindkey -M vicmd 'gk' tmux-select-pane-up

tmux-select-pane-down () {
    tmux select-pane -D
}
zle -N tmux-select-pane-down
bindkey -M vicmd 'gj' tmux-select-pane-down

tmux-select-pane-left () {
    tmux select-pane -L
}
zle -N tmux-select-pane-left
bindkey -M vicmd 'gh' tmux-select-pane-left

tmux-select-pane-right () {
    tmux select-pane -R
}
zle -N tmux-select-pane-right
bindkey -M vicmd 'gl' tmux-select-pane-right
# }}}
# Keybindings {{{
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward
bindkey '^E' push-line
bindkey '^N' edit-command-line
bindkey '^H' run-help 

bindkey -M vicmd '^N' edit-command-line

# Ctrl-z -> If there is a suspended process, bring it to foreground
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Ctrl-S -> insert sudo at the beginning of the line
function prepend-sudo {
  if [[ $BUFFER == "sudo "* ]]; then
    BUFFER=$(echo $BUFFER | sed 's/^sudo //')
  else
    BUFFER="sudo $BUFFER"
    CURSOR+=5
  fi
}
zle -N prepend-sudo
bindkey "^s" prepend-sudo
# }}}
# Environment Variables {{{
export EDITOR="nvim"

if [[ $os == "linux" ]]; then
    export BROWSER="google-chrome-stable"
fi

export PATH="$PATH:/bin:/usr/local/games:/usr/games:$HOME/.local/bin:$HOME/node_modules/.bin"
export MANPATH="$MANPATH:$HOME/.local/man"

if type go > /dev/null; then
    export GOPATH=$(go env GOPATH)
    export PATH=$PATH:$GOPATH/bin
fi
# }}}
# External Tools {{{
if [[ -r "$HOME/.local/share/z/z.sh" ]]; then
    source "$HOME/.local/share/z/z.sh"
elif [[ -r "/usr/share/z/z.sh" ]]; then
    source "/usr/share/z/z.sh"
fi

# Enable bash completion scripts
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Auto-complete for pipx
if type pipx > /dev/null; then
    eval "$(register-python-argcomplete pipx)"
fi

if type pyenv > /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi


if type terraform > /dev/null; then
    complete -o nospace -C $(where terraform) terraform
fi
# }}}
# Source other configs {{{
if [[ -f "$HOME/.zshrc_local" ]]; then
    source "$HOME/.zshrc_local"
fi
# }}}
# Aliases {{{
if type lsd > /dev/null; then
    alias ls='lsd'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -lh'
alias la='ll -a'
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
alias tree='tree -C'
alias vi='nvim'
alias vim='nvim'
alias s='sudo'
alias se='sudoedit'
alias pac='pikaur'
if [[ $OSTYPE == 'linux'* ]]; then
    alias open='xdg-open'
fi
alias wget='wget -c'
alias lynx='lynx -lss=~/.lynx.lss'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias info='info --vi-keys'      # GNU info act like man command
alias emacs='emacs -nw'          # cli mode
alias cdtmp='cd $(mktemp -d)'
alias rm='rm -rf'
alias dad="curl -k https://icanhazdadjoke.com/ && echo"
alias cb-copy="xclip -selection clipboard"

if type thefuck > /dev/null; then
    eval $(thefuck --alias)
else
    alias fuck='eval "sudo $(fc -ln -1)"'
fi

# Global aliases are a zsh-specific feature
if [ -n "$ZSH_VERSION" ]; then
    alias -g G='| grep -i'
    alias -g L='| less'
    alias -g H='| head'
    alias -g T='| tail'
fi

function mkcd() { mkdir -p "$@" && cd "$_"; }
function yadm_update() {
    local commit_msg="Updated dotfiles $(date +'%Y-%m-%d %H:%M %Z') from $(yadm config local.class)"
    yadm commit -am "$commit_msg" && yadm push;
}

function venv {
    if [[ -f "pdm.lock" ]]; then
        venv_path=$(pdm venv --path in-project)
    elif [[ -f "poetry.lock" ]]; then
        venv_path=$(poetry env info -p)
    elif [[ -f "Pipfile.lock" ]]; then
        venv_path=$(pipenv --venv)
    else
        echo "No pdm.lock, poetry.lock or Pipfile.lock found :("
        return 1
    fi

    source $venv_path/bin/activate
}

function review_pass {
    filename=$(find ~/7bridges -name populate_dev_users.py)
    password=$(cat $filename| grep set_password | sed "s/.*set_password('\(.*\)')/\1/")

    echo $password

    if type xclip > /dev/null; then
        echo -n $password | xclip -selection clipboard
    fi
}

if [[ $OSTYPE == 'darwin'* ]]; then
    if type brew > /dev/null && type pyenv > /dev/null; then
        alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
    fi
fi
# }}}
