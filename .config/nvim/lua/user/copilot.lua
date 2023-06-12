local status_ok, copilot = pcall(require, "copilot")
if not status_ok then
    return
end

-- local NODE_VERSION_TO_USE = "v20.*"
--
-- local get_nvm_node_dir = function(path)
--     local entries = {}
--     local handle = vim.loop.fs_scandir(path)
--
--     if type(handle) == 'userdata' then
--         local function iterator()
--             return vim.loop.fs_scandir_next(handle)
--         end
--
--         for name in iterator do
--             local absolute_path = path .. '/' .. name
--             local relative_path = vim.fn.fnamemodify(absolute_path, ':.')
--             local version_match = relative_path:match(NODE_VERSION_TO_USE)
--
--             if version_match ~= nil then
--                 table.insert(entries, absolute_path)
--             end
--         end
--
--         table.sort(entries)
--     end
--
--     return entries[#entries]
-- end
--
-- local node_fallback = function()
--     local node_path = vim.fn.exepath("node")
--
--     if not node_path then
--         vim.notify("`node` not found in path", vim.log.levels.ERROR)
--         return
--     end
--
--     return node_path
-- end
--
-- local resolve_node_cmd = function()
--     local nvm_dir = vim.fn.expand('$NVM_DIR')
--
--     if nvm_dir == "$NVM_DIR" then
--         return node_fallback()
--     end
--
--     nvm_dir = nvm_dir .. "/versions/node"
--     local node = get_nvm_node_dir(nvm_dir)
--
--     vim.notify(vim.inspect(node))
--     if not node then
--         return node_fallback()
--     end
--     node = node .. "/bin/node"
--     return node
-- end

copilot.setup({
    -- copilot_node_command = resolve_node_cmd(),
    suggestion = {
        auto_trigger = true,
        keymap = {
            accept = "<C-j>",
            next = "<C-l>",
            prev = "<C-h>",
            dismiss = "<C-k>",
        },
    }
})
