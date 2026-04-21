-- ref: https://www.youtube.com/watch?v=_U54QKdFQno
local my_utils = require("utils")

-- default menu defined in $VIMRUNTIME/lua/vim/_core/defaults.lua

local function add_popup_menu_item(name, action, opts)
    opts = my_utils.apply_defaults(opts, { mode = "a", remap = false })

    local menu_cmd = opts.mode .. (opts.remap and "" or "nore") .. "menu"

    local menu_name = "PopUp." .. name:gsub(" ", "\\ ")
    vim.cmd(string.format("%s %s %s", menu_cmd, menu_name, action))
end

vim.cmd([[aunmenu PopUp]])
local group = vim.api.nvim_create_augroup("nvim.popupmenu", { clear = true })
add_popup_menu_item("Open", "gx", { remap = true })
add_popup_menu_item("-1-", "<Nop>")
add_popup_menu_item("Inspect", "<Cmd>Inspect<CR>")
add_popup_menu_item("Go to Definition", "<Cmd>lua vim.lsp.buf.definition()<CR>")
add_popup_menu_item("-2-", "<Nop>")
add_popup_menu_item("Jumplist Back", "<Cmd>lua require('bufjump').backward()<CR>", { mode = "n" })
add_popup_menu_item("Jumplist Forward", "<Cmd>lua require('bufjump').forward()<CR>", { mode = "n" })
add_popup_menu_item("-3-", "<Nop>")
add_popup_menu_item("Reload Config", "<Cmd>ReloadConfig<CR>")

-- vim.cmd([[
--     aunmenu PopUp
--     amenu PopUp.Open     gx
--     anoremenu PopUp.-1-                        <Nop>
--     anoremenu PopUp.Inspect                    <Cmd>Inspect<CR>
--     anoremenu PopUp.Go\ to\ Definition         <Cmd>lua vim.lsp.buf.definition()<CR>
--     anoremenu PopUp.-2-                        <Nop>
--     nnoremenu PopUp.Jumplist\ Back      <Cmd>lua require('bufjump').backward()<CR>
--     nnoremenu PopUp.Jumplist\ Forward      <Cmd>lua require('bufjump').forward()<CR>
-- ]])
--
--
-- vim.api.nvim_create_autocmd("MenuPopup", {
--     pattern = "*",
--     group = group,
--     desc = "Custom popup menu",
--     callback = function()
--         vim.cmd([[
--             amenu disable PopUp.Go\ to\ Definition
--         ]])
--         if vim.lsp.get_clients({ bufnr = 0 })[1] then
--             vim.cmd([[
--                 amenu enable PopUp.Go\ to\ Definition
--             ]])
--         end
--     end,
-- })
