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

plugins=(git git-extras zsh-syntax-highlighting vi-mode zle-vi-visual)
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
NORMAL_MODE_INDICATOR="%{$fg_bold[green]%}-%{$fg[green]%}- NORMAL --%{$reset_color%}"
INSERT_MODE_INDICATOR="%{$fg_bold[blue]%}-%{$fg[blue]%}- INSERT --%{$reset_color%}"
VISUAL_MODE_INDICATOR="%{$fg_bold[magenta]%}-%{$fg[magenta]%}- VISUAL --%{$reset_color%}"

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

function _vim_mode_prompt_info() {
	case $KEYMAP in
		vicmd)
			echo "$NORMAL_MODE_INDICATOR"
			;;
		viins||main)
			echo "$INSERT_MODE_INDICATOR"
			;;
		vivis)
			echo "$VISUAL_MODE_INDICATOR"
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

RPS1='$(_vim_mode_prompt_info)'

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
export BROWSER="google-chrome-stable"

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
# }}}
# Source other configs {{{
if [[ -f "$HOME/.aliases" ]]; then
	source $HOME/.aliases
fi

if [[ -f "$HOME/.zshrc_local" ]]; then
	source "$HOME/.zshrc_local"
fi
# }}}
