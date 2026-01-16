#!/bin/bash

# Intended to be used in tmux.conf when switching sessions using a keybind (e.g. C-a s),
# or when launching tmux for the first time. If modifying this script consider also modifying
# .tmux.conf (keybinds) and .zshrc/.zprofile (aliases/functions) accordingly

# Based on: https://github.com/joshmedeski/sesh?tab=readme-ov-file#tmux--fzf

# TODO: unify with the tmux-new-session-template.py script

if [[ -n "${DEBUG:-}" ]]; then
    if tmux info &> /dev/null; then 
        echo "tmux server running"
    else
        echo "tmux server not running"
    fi

    if [[ -n "$TMUX" ]]; then
        echo "running inside tmux"
    else
        echo "running outside tmux"
    fi

    echo "debug mode info completed, press any key to continue"
    read -n 1
fi

# NOTE: --hide-duplicates of sesh list doesn't work as expected as it hides them based on the path and that path
# is always set to "" for tmuxinator sessions (see sesh list --json --tmuxinator). As a workarround we use the
# awk command to filter out duplicates based on the second column (the session name). Also that way we don't need to
# rely on the path being unique as this is not the case for some dotfile sessions

# NOTE: awk '!seen[$2]++' removes duplicate session names based on the second column -- session name,
#       the first one is the icon


# --bind 'enter:transform:[[ -n {} ]] && echo accept || echo "execute(tmux new -s {q} -d && sesh connect {q})+abort"' \

selected_session=$(sesh list --tmux --tmuxinator --config --icons \
    | awk '!seen[$2]++' \
    | fzf-tmux -p 80%,70% \
        --no-sort --ansi --reverse \
        --border-label ' sesh ' \
        --prompt '⚡  ' \
        --bind 'start,change:change-header(^a all ^g configs ^x zoxide ^d kill ^f find)' \
        --bind 'zero:change-header(Session not found, press Enter to create it and switch to it)' \
        --bind 'tab:down,btab:up' \
        --bind "enter:transform:[[ -n {} ]] && echo accept || echo \"execute(~/.local/bin/tmux-new-session-template {q} && sesh connect {q})+abort\"" \
        --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
        --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list --icons --config --tmuxinator)' \
        --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list --icons --zoxide)' \
        --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~/dev)' \
        --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --tmux --tmuxinator --config --icons)' \
        --preview-window 'right:55%' \
        --preview 'sesh preview {}' \
)

if [[ -n "${DEBUG:-}" ]]; then
    echo "selected session: $selected_session"
    read -n 1 -s -r -p "Press any key to continue"
    echo
fi

if [[ -n "$selected_session" ]]; then
    sesh connect "$selected_session"
fi



