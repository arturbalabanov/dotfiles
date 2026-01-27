#!/usr/bin/env bash

popup_command() {
    local title=$1
    local command=$2
    echo "display-popup -E -w 90% -h 90% -y C -x C -T \"#[bold,fg=green]$title#[default] [#{pane_current_path}]\" \"$command\""
}

lazydocker_popup="$(popup_command 'lazydocker' 'lazydocker')"
lazygit_popup="$(popup_command 'lazygit' 'lazygit')"
claude_popup="$(popup_command 'ClaudeAI' 'claude')"

# shellcheck disable=2068
tmux display-menu $@ -T "tmux right click" \
    "-Sessions" '' '' \
    " New" "n" 'new-session' \
    " Switch" "s" 'run ~/scripts/tmux-select-session.sh' \
    "" \
    "-Floating panes" '' '' \
    " lazydocker" "d" "$lazydocker_popup" \
    " lazygit" "g" "$lazygit_popup" \
    "  ClaudeAI" "a" "$claude_popup" \
    "" \
    "-Kitty scripts" '' '' \
    "  New OS window" '' 'run ~/scripts/kitty-new-win' \
    "  Toggle window decorations" '' 'run ~/scripts/kitty-toggle-win-decorations'
