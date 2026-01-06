# Utilities {{{
function _has_brew {
    [[ \
        $OSTYPE == 'darwin'* \
        && $(uname -m) == "arm64" \
        && -d "/opt/homebrew" \
    ]]
}

function _exists {
    type $1 2>&1 > /dev/null
}

function _error {
    if [[ $# -eq 0 ]]; then
        echo "error: no arguments given" >&2
        return 1
    fi

    msg="$1"
    exit_code="${2:-1}"

    echo "error: $msg" >&2
    return $exit_code
}

function _in_git_repo {
    git rev-parse --is-inside-work-tree 2>&1 > /dev/null
}

function _register_python_argcomplete {
    if [[ $# -ne 1 ]]; then
        _error "_register_python_argcomplete: exactly one argument is required"
    fi

    if ! _exists register-python-argcomplete; then
        _error "_register_python_argcomplete: register-python-argcomplete not found (install 'argcomplete' via pip / uvx / pipx)"
    fi

    binary="$1"

    if ! _exists "$binary"; then
        _error "_register_python_argcomplete: '$binary' not found"
    fi

    eval "$(register-python-argcomplete $binary)"
}
# }}}
# Oh my ZSH {{{
export ZSH=$HOME/.oh-my-zsh

if _exists starship; then
    eval "$(starship init zsh)"
else
    ZSH_THEME="artur" 
fi

export DISABLE_AUTO_UPDATE="true"
export DISABLE_AUTO_TITLE="true"
export HIST_STAMPS="dd.mm.yyyy"

if _has_brew; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

plugins=(zsh-syntax-highlighting vi-mode zle-vi-visual)

source $ZSH/oh-my-zsh.sh
# }}}
# Colors and Text Formatting {{{
if _exists vivid; then
    export LS_COLORS="$(vivid generate tokyonight-night)"
elif test -r ~/.dircolors; then
    if _exists gdircolors; then
        alias dircolors=gdircolors
    fi

    if _exists dircolors; then
        eval $(dircolors ~/.dircolors)
    fi
fi
# man page colors
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking 
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold 
export LESS_TERMCAP_me=$'\E[0m'           # end mode 
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode 
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box 
export LESS_TERMCAP_ue=$'\E[0m'           # end underline 
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

export LESS="$LESS -x4"  # less uses 4 space tab witdh

tabs -4  # tab width 4 spaces
# }}}
# Terminal wizardry {{{
# Stupid Ctrl-S!
stty -ixon
# }}}
# VIM Mode {{{
function _get_zsh_vim_mode {
    case $KEYMAP in
        vicmd)
            echo -n 'normal'
            ;;
        viins||main)
            echo -n 'insert'
            ;;
        vivis)
            echo -n 'visual'
            ;;
    esac
}


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
    vim_mode=$(_get_zsh_vim_mode)

    case $vim_mode in
        normal)
            _set_cursor_shape "block"
            ;;
        insert)
            _set_cursor_shape "line"
            ;;
        visual)
            _set_cursor_shape "block"
            ;;
    esac

    _write_vi_mode_to_file_per_process

    zle reset-prompt
    zle -R
}

function zle-line-finish {
    _set_cursor_shape "block"
    _write_vi_mode_to_file_per_process
}

function _write_vi_mode_to_file_per_process {
    echo $(_get_zsh_vim_mode) > /tmp/zsh_vim_mode_$$
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-finish

# Vim mode keybindings
bindkey -M viins 'jj' vi-cmd-mode

bindkey -M vicmd 'H' beginning-of-line
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
# External Tools {{{
# asdf
if _exists asdf && _has_brew; then
    source $(brew --prefix asdf)/libexec/asdf.sh
fi

# 1Password CLI (op)
if _exists op; then
    if [[ -f "~/.config/op/plugins.sh" ]]; then
        source "~/.config/op/plugins.sh"
    fi
fi

# pdflatex
# The brew package is called 'basictex' but it's installed in a weird location
# which is why wee need to do th this.
#
# ref: https://superuser.com/q/1038612
if _has_brew; then
    if [[ -d "/Library/TeX/texbin" ]]; then
        export PATH="$PATH:/Library/TeX/texbin"
    fi
fi


# }}}
# Autocomlete setup {{{

# Load ZSH modules for completions {{{
# refs:
#
# * https://thevaluable.dev/zsh-completion-guide-examples/
# * https://www.bash2zsh.com/zsh_refcard/refcard.pdf
# * https://stackoverflow.com/a/23568183 
# * http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors

# ===== CHEATSHEET =======
#
# :completion:<function>:<completer>:<command>:<argument>:<tag>
#
# format explanation:
#    %B ... %b  -> bold
#    %d -- description string
#
# list-colors is using the LS_COLORS syntax
#
# 00	Default colour
# 01	Bold
# 04	Underlined
# 05	Flashing text
# 07	Reversetd
# 08	Concealed
#
# 30	Black
# 31	Red
# 32	Green
# 33	Orange
# 34	Blue
# 35	Purple
# 36	Cyan
# 37	Grey
#
# 40	Black background
# 41	Red background
# 42	Green background
# 43	Orange background
# 44	Blue background
# 45	Purple background
# 46	Cyan background
# 47	Grey background

# Group the completions by type of matches
zstyle ':completion:*' group-name ''  

# Style the group names
zstyle ':completion:*:descriptions' format "$fg[yellow]%B%d%b"

# Detailed List of Files and Folders
# zstyle ':completion:*' file-list all
# Colorize completions using default `ls` colors.
zstyle ':completion:*:*:*:default' list-colors "${(s.:.)LS_COLORS}"

# zstyle ':completion:*:options' list-colors "=(#b)(-[^ ]#|--[^ ]#)*(--*)=$color[white]=$color[blue]=$color[white]"
# zstyle ':completion:*:commands' list-colors '=*=1;31'


# }}}

# Alias auto expand {{{

# ref: https://github.com/rothgar/mastering-zsh/blob/master/docs/helpers/aliases.md#automatically-expand-aliases

globalias() {
   zle _expand_alias
   zle expand-word
   zle self-insert
}
zle -N globalias

# space expands all aliases, including global
bindkey -M emacs " " globalias
bindkey -M viins " " globalias

# control-space to make a normal space
bindkey -M emacs "^ " magic-space
bindkey -M viins "^ " magic-space

# normal space during searches
bindkey -M isearch " " magic-space
# }}}

if _exists fzf && _has_brew; then
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi

if _exists zoxide; then
    eval "$(zoxide init zsh)"
fi

if _exists pipx; then
    if _exists pyenv; then
        # Use the global pyenv python version for all pipx packages,
        # so that when the system python updates, the installed packages
        # are not affected
        export PIPX_DEFAULT_PYTHON="$(pyenv root)/versions/$(pyenv global)/bin/python"
    fi

    _register_python_argcomplete pipx
fi

if _exists terraform; then
    complete -o nospace -C $(where terraform) terraform
fi

if _exists uv; then
    eval "$(uv generate-shell-completion zsh)"

    if _exists uvx; then
        eval "$(uvx --generate-shell-completion zsh)"
    fi

    # add autocompletion when using: uv run [Tab]
    # ref: https://github.com/astral-sh/uv/issues/8432#issuecomment-2605216865

    _uv_run_mod() {
        if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
            local venv_binaries
            if [[ -d .venv/bin ]]; then
                venv_binaries=( ${(@f)"$(_call_program files ls -1 .venv/bin 2>/dev/null)"} )
            fi
            
            _alternative \
                'files:filename:_files' \
                "binaries:venv binary:(($venv_binaries))"
        else
            _uv "$@"
        fi
    }
    compdef _uv_run_mod uv
fi

if _exists jira; then
    eval "$(jira completion zsh)"
fi

if _exists docker; then
    eval "$(docker completion zsh)"
fi

# make & remake {{{

# Enable autocomplete for dynamic make targes
#
# ref: https://github.com/zsh-users/zsh-completions/issues/813#issuecomment-902592371

zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:make:*:variables' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets'

zstyle ':completion:*:remake:*:targets' call-command true
zstyle ':completion:*:remake:*:variables' call-command true
zstyle ':completion:*:*:remake:*' tag-order 'targets'
# }}}

# }}}
# Aliases {{{
if _exists lsd; then
    alias ls='lsd'
    alias tree='lsd -l --tree'
else
    alias ls='ls --color=auto'
    alias tree='tree -C'
fi
alias ll='ls -lh'
alias la='ll -a'
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
alias vi='nvim'
alias vim='nvim'
alias s='sudo'
alias se='sudoedit'
alias pac='pikaur'
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
alias gst="git status"
alias glog="git log"

# docker compose aliases
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dce='docker compose exec'
alias dcw='docker compose watch --no-up'

if ! _exists pbcopy; then   # pbcopy and pbpaste are macOS specific
    if _exists xclip; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif _exists xsel; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi

if _exists thefuck; then
    eval $(thefuck --alias)
else
    alias fuck='eval "sudo $(fc -ln -1)"'
fi

if _exists act && _exists gh; then
    original_act=$(type act | sed 's/^act is //')

    function act {
        $original_act -s GITHUB_TOKEN="$(gh auth token)" $@
    }
fi

function _debug_alias {
    local before_alias=$(echo $BUFFER | sed s/\$\($0\)//)
    
    if [[ $before_alias =~ "pytest " ]]; then
        echo "-vvv -o log_cli=true -o log_cli_level=INFO"
        return
    fi

    # Default to the original alias (i.e. don't expand)
    echo "D"
}

alias -g G='| grep -i'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g D='$(_debug_alias)'

if _exists fzf; then
    alias -g F='| fzf'

    if _exists fd; then
        function ivim {
            fzf_args=""

            if [[ "$#" -eq 1 ]]; then
                fzf_args="--query=$1"
            elif [[ "$#" -gt 1 ]]; then
                fzf_args="$@"
            fi

            preview_cmd='bat {}'

            vim $(fd --type=file | fzf $fzf_args)
        }

        function icd {
            fzf_args=""

            if [[ "$#" -eq 1 ]]; then
                fzf_args="--query=$1"
            elif [[ "$#" -gt 1 ]]; then
                fzf_args="$@"
            fi

            preview_cmd='lsd -l --depth 2 --tree --color=always {} | head -100'

            cd $(fd --type=directory | fzf $fzf_args --preview ${preview_cmd})
        }
    fi

    function gco {
        if ! _in_git_repo; then
            _error "not in a git repo"
            return 1
        fi

        fzf_args=""

        if [[ "$#" -eq 1 ]]; then
            git checkout $1 2> /dev/null

            if [[ "$?" -eq 0 ]]; then
                # successfully checked out to that branch
                return 0
            fi

            # set the argument to the initial query
            fzf_args="--query=$1"
        fi

        preview_cmd="git log {} --color=always --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset) %C(dim white)- %an%C(reset)%n''          %s'"

        git branch --sort=-committerdate \
            | grep -v '^\*' \
            | sed -E 's/^[[:space:]]*//' \
            | fzf $fzf_args --preview $preview_cmd \
            | xargs git checkout
    }

fi

function mkcd() { mkdir -p "$@" && cd "$_"; }

function venv {
    if [[ -f "pdm.lock" ]]; then
        venv_path=$(pdm venv --path in-project)
    elif [[ -f "poetry.lock" ]]; then
        venv_path=$(poetry env info -p)
    elif [[ -f "Pipfile.lock" ]]; then
        venv_path=$(pipenv --venv)
    elif [[ -f ".venv/bin/activate" ]]; then
        venv_path=".venv"
    else
        echo "No pdm.lock, poetry.lock, Pipfile.lock or .venv found :("
        return 1
    fi

    source $venv_path/bin/activate
}

function ssh {
    if [[ $# -eq 0 ]]; then
        hosts=$(cat \
            <(cat ~/.ssh/known_hosts | awk '{ print $1 }') \
            <(cat ~/.ssh/config | grep -i '^Host \w' | awk '{ print $2 }') \
            | grep -i -v '127\.0\.0\.1\|0\.0\.0\.\0\|localhost' \
            | sort -u \
        )

        host=$(echo "$hosts" | fzf --info inline-right --layout reverse --preview 'dig {}' --height 15 --no-sort)
        
        if [[ $TERM == "xterm-kitty" ]]; then
            TERM="xterm-256color" command ssh "$host"
        else
            command ssh "$host"
        fi
    else
        if [[ $TERM == "xterm-kitty" ]]; then
            TERM="xterm-256color" command ssh $@
        else
            command ssh $@
        fi
    fi
    
}

if _exists tmux && _exists sesh; then
    function tmux {
        # if running tmux with arguments, just pass them through to the original tmux command
        if [[ $# -gt 0 ]]; then
            command tmux $@
            return
        fi

        $HOME/scripts/tmux-select-session.sh
    }
fi
# }}}
# Source other configs {{{
if [[ -f "$HOME/.zshrc_local" ]]; then
    source "$HOME/.zshrc_local"
fi
# }}}
