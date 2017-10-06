# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster" 

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true" 

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

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

bindkey -M vivis 'H' vi-visual-bol
bindkey -M vivis 'L' vi-visual-eol

# For the zsh theme -- if the user is DEFAULT_USER, it is not shown
export DEFAULT_USER="cap"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
# export DEFAULT_USER="artur"
export EDITOR="nvim"
# export BROWSER="vivaldi"
export BROWSER="google-chrome-stable"

source $HOME/.aliases

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

PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'

bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward
bindkey '^E' push-line
bindkey '^N' edit-command-line
bindkey '^H' run-help 

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

export PATH=$PATH:/bin:/usr/local/games:/usr/games:$HOME/.local/bin

# export PATH=$PATH:/home/artur/.gem/ruby/2.1.0/bin
# export PATH="$PATH:/usr/local/share/npm/bin"
# export PATH="$PATH:/usr/local/lib/node_modules/karma/bin"
 export PATH="$PATH:$HOME/node_modules/.bin"

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/projects
# source /usr/bin/virtualenvwrapper.sh
# source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

export CAP_tools_home=/home/cap/dev/cap
export CDP_HOME=/home/cap/dev/cdp
export CPY_HOME=/home/cap/dev/cpy
export MY_UTILS=/home/cap/dev/my_utils

export PATH=$PATH:$CAP_tools_home/bin:$CDP_HOME/bin:$CDP_HOME/lib:/home/cap/dev/casperjs/bin:/home/cap/dev/phantomjs/bin:/home/cap/dev/slimerjs-0.9.4:/home/cap/dev/cpy/bin:/home/cap/dev/local_cap:$MY_UTILS/bin
export PYTHONPATH=/home/cap/dev/cpy

export GPGKEY=7EEF6612

PATH="/home/cap/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/cap/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/cap/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/cap/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/cap/perl5"; export PERL_MM_OPT;

export NVM_DIR="/home/cap/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

if [ -n "$ZSH_VERSION" ]; then
else
	eval "$(python $CPY_HOME/cpy/develop/runtime/autocomplete.py)"
fi
 
export PATH="$HOME/neovim/bin:$PATH"

export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
