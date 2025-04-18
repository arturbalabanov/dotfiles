return {
  "Wansmer/treesj",
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  keys = {
    { "sj", "<cmd>TSJSplit<CR>", desc = "Split node under cursor" },
    { "sk", "<cmd>TSJJoin<CR>",  desc = "Join node under cursor" },
  },
  opts = {
    use_default_keymaps = false,

    -- Node with syntax error will not be formatted
    check_syntax_error = true,

    -- If line after join will be longer than max value,
    -- node will not be formatted
    max_join_length = 120,

    -- hold|start|end:
    -- hold - cursor follows the node/place on which it was called
    -- start - cursor jumps to the first symbol of the node being formatted
    -- end - cursor jumps to the last symbol of the node being formatted
    cursor_behavior = 'hold',

    -- Notify about possible problems or not
    notify = true,

    -- Use `dot` for repeat action
    dot_repeat = false,
  },
}
