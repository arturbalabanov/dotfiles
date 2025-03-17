local keymap

if vim.g.neovide then
    keymap = "<C-/>"
elseif vim.env.ZELLIJ ~= nil or vim.env.TMUX ~= nil then
    -- NOTE: In some terminals (or in tmux & zellij) C-/ is triggered by C-_
    keymap = "<C-_>"
else
    keymap = "<C-/>"
end

return {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
        mappings = {
            comment_line = keymap,
            comment_visual = keymap,
        },
    },
}
