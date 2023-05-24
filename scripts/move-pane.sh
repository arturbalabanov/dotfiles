#!/bin/bash

# An extended verson of vim-tmux-navigator
# ref: https://github.com/christoomey/vim-tmux-navigator

if [ "$(uname)" == "Darwin" ]; then
    plat="macos"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    plat="linux"
fi

direction=$1
keybinding=$2

pane_tty=$(tmux display -p '#{pane_tty}')

# TODO: There is a bug (or a feature?) in `poetry shell` where ps doesn't
# report the subprocesses following that one, so this detection doesn't work.
# Find a workarround for this.
is_vim=$(ps -o state= -o comm= -t "$pane_tty" | grep -iE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$')

if [[ "$3" != "--ignore_vim" && -n $is_vim ]]; then
    tmux send-keys $keybinding
    exit 0
fi

pane_at_bottom=$(tmux display -p '#{pane_at_bottom}')
pane_at_top=$(tmux display -p '#{pane_at_top}')
pane_at_left=$(tmux display -p '#{pane_at_left}')
pane_at_right=$(tmux display -p '#{pane_at_right}')

if [[ ! ( \
    ($direction == "-D" && $pane_at_bottom == "1") || \
    ($direction == "-U" && $pane_at_top == "1") || \
    ($direction == "-L" && $pane_at_left == "1") || \
    ($direction == "-R" && $pane_at_right == "1") \
) ]]; then
    tmux select-pane "$direction"
    exit 0
fi

if [[ "$plat" == "linux" ]]; then
    # Convert to HEX since all the other commands use that format
    curr_win_id=$(printf '0x%08x' $(xdotool getactivewindow))

    read -r \
        curr_win_id \
        curr_desktop_id \
        curr_win_x \
        curr_win_y \
        curr_win_w \
        curr_win_h \
        curr_win_class \
        curr_hostname \
        curr_win_title \
        < <(wmctrl -lGx | awk -v curr_win_id=$curr_win_id '$1 == curr_win_id')

    while read -r win_id desktop_id win_x win_y win_w win_h win_class hostname win_title; do
        if [[ $win_id == $curr_win_id || ! $win_class =~ 'urxvt' ]]; then
            continue
        fi

        if [[ $direction == "-D" && $(expr $curr_win_y + $curr_win_h) == $win_y ]]; then
            pane_flag="pane_at_bottom"
        elif [[ $direction == "-U" && $(expr $win_y + $win_h) == $curr_win_y ]]; then
            pane_flag="pane_at_top"
        elif [[ $direction == "-L" && $(expr $win_x + $win_w) == $curr_win_x ]]; then
            pane_flag="pane_at_left"
        elif [[ $direction == "-R" && $(expr $curr_win_x + $curr_win_w) == $win_x ]]; then
            pane_flag="pane_at_right"
        else
            continue
        fi

        xdotool windowactivate "$win_id"
        # target_pane_id=$(tmux list-panes -F "#{$pane_flag} #{pane_id}" | grep '^1\b' | head -1 | sed 's/1 //')
        # tmux select-pane -t $target_pane_id
    done < <(wmctrl -lGx)
fi
