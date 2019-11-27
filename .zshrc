# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="artur" 

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true" 

# Comment this out to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-extras npm zsh-syntax-highlighting vi-mode zle-vi-visual tmuxinator) # zsh-autosuggestions

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

NORMAL_MODE_INDICATOR="%{$fg_bold[green]%}-%{$fg[green]%}- NORMAL --%{$reset_color%}"
INSERT_MODE_INDICATOR="%{$fg_bold[blue]%}-%{$fg[blue]%}- INSERT --%{$reset_color%}"
VISUAL_MODE_INDICATOR="%{$fg_bold[magenta]%}-%{$fg[magenta]%}- VISUAL --%{$reset_color%}"

function vim_mode_prompt_info() {
  echo "${${${KEYMAP/vicmd/$NORMAL_MODE_INDICATOR}/(main|viins)/$INSERT_MODE_INDICATOR}/(vivis)/$VISUAL_MODE_INDICATOR}"
}

RPS1='$(vim_mode_prompt_info)'

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

export EDITOR="nvim"
export BROWSER="google-chrome-stable"

eval $(dircolors ~/.dircolors)

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

# PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'

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

export PATH=$PATH:/bin:/usr/local/games:/usr/games:$HOME/.local/bin
export MANPATH="$MANPATH:$HOME/.local/man"

export PATH="$PATH:$HOME/node_modules/.bin"

if [[ -r "$HOME/.local/share/z/z.sh" ]]; then
	source "$HOME/.local/share/z/z.sh"
elif [[ -r "/usr/share/z/z.sh" ]]; then
	source "/usr/share/z/z.sh"
fi

DEFAULT_PYTHON_VERSION=$(python -c "import sys; print(sys.version_info[0])")

# Disable the default (virtualenv) in front of the prompt
# This will enable it as a seperate sector which is way more beautiful
VIRTUAL_ENV_DISABLE_PROMPT=1

source $HOME/.aliases
if [[ -f "$HOME/.zshrc_local" ]]; then
	source "$HOME/.zshrc_local"
fi


