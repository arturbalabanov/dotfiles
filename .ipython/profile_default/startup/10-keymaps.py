from functools import partial

from IPython import get_ipython
from prompt_toolkit.enums import DEFAULT_BUFFER
from prompt_toolkit.filters import HasFocus, vi_insert_mode, vi_navigation_mode, vi_selection_mode, Condition
from prompt_toolkit.key_binding.vi_state import InputMode

ipython = get_ipython()


# refs:
#   * https://ipython.readthedocs.io/en/stable/config/details.html#keyboard-shortcuts 
#   * https://python-prompt-toolkit.readthedocs.io/en/latest/pages/advanced_topics/key_bindings.html


if not getattr(ipython, 'pt_app', None):
    raise TypeError("ipython doesn't have a pt_app attribute. Perhaps using an old version?")


keymap = ipython.pt_app.key_bindings

ikeymap = partial(keymap.add, filter=(HasFocus(DEFAULT_BUFFER) & vi_insert_mode))
nkeymap = partial(keymap.add, filter=(HasFocus(DEFAULT_BUFFER) & vi_navigation_mode))
vkeymap = partial(keymap.add, filter=(HasFocus(DEFAULT_BUFFER) & vi_selection_mode))
nvkeymap = partial(keymap.add, filter=(
    HasFocus(DEFAULT_BUFFER) & (vi_navigation_mode | vi_selection_mode)
))

@ikeymap('j', 'j')
def switch_to_navigation_mode(event):
    vi_state = event.cli.vi_state
    vi_state.input_mode = InputMode.NAVIGATION


@nkeymap('H')
def go_to_start_of_line_after_ws(event):
    buf = event.current_buffer
    start_line_pos = buf.document.get_start_of_line_position(after_whitespace=True)
    buf.cursor_position += start_line_pos


@nkeymap('L')
def go_to_end_of_line(event):
    buf = event.current_buffer
    end_line_pos = buf.document.get_end_of_line_position()
    buf.cursor_position += end_line_pos
