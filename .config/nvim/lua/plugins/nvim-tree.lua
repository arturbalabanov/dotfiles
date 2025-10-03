-- NOTE: Keymap set in keymaps.lua as it's conditional (toggle nvim-tree or
-- diff view file history depending on whether in diff mode or not)

return {
    "nvim-tree/nvim-tree.lua",
    tag = "nvim-tree-v1.2.0",
    init = function()
        -- disable netrw at the very start of your init.lua
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- optionally enable 24-bit colour
        vim.opt.termguicolors = true
    end,
    opts = {
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
            enable = true,
            update_root = true,
        },
        notify = {
            threshold = vim.log.levels.WARN, -- only notify on warnings or above
            absolute_path = false,
        },
        on_attach = function(bufnr)
            local function nkeymap(input, action, desc)
                require("utils.keymap").set_n(input, action, {
                    desc = "nvim-tree: " .. desc,
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true,
                })
            end

            local api = require("nvim-tree.api")

            -- addapted from: https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree/keymap.lua
            nkeymap("<C-]>", api.tree.change_root_to_node, "CD")
            nkeymap("<C-e>", api.node.open.replace_tree_buffer, "Open: In Place")
            nkeymap("<C-k>", api.node.show_info_popup, "Info")
            nkeymap("<C-r>", api.fs.rename_sub, "Rename: Omit Filename")
            nkeymap("<C-t>", api.node.open.tab, "Open: New Tab")
            nkeymap("t", api.node.open.tab, "Open: New Tab")
            nkeymap("<C-v>", api.node.open.vertical, "Open: Vertical Split")
            nkeymap("<C-x>", api.node.open.horizontal, "Open: Horizontal Split")
            nkeymap("<BS>", api.node.navigate.parent_close, "Close Directory")
            nkeymap("<CR>", api.node.open.edit, "Open")
            nkeymap("<Tab>", api.node.open.preview, "Open Preview")
            nkeymap(">", api.node.navigate.sibling.next, "Next Sibling")
            nkeymap("<", api.node.navigate.sibling.prev, "Previous Sibling")
            nkeymap(".", api.node.run.cmd, "Run Command")
            nkeymap("-", api.tree.change_root_to_parent, "Up")
            nkeymap("a", api.fs.create, "Create File Or Directory")
            nkeymap("bd", api.marks.bulk.delete, "Delete Bookmarked")
            nkeymap("bt", api.marks.bulk.trash, "Trash Bookmarked")
            nkeymap("bmv", api.marks.bulk.move, "Move Bookmarked")
            nkeymap("B", api.tree.toggle_no_buffer_filter, "Toggle Filter: No Buffer")
            nkeymap("c", api.fs.copy.node, "Copy")
            nkeymap("C", api.tree.toggle_git_clean_filter, "Toggle Filter: Git Clean")
            nkeymap("[c", api.node.navigate.git.prev, "Prev Git")
            nkeymap("]c", api.node.navigate.git.next, "Next Git")
            nkeymap("d", api.fs.remove, "Delete")
            nkeymap("D", api.fs.trash, "Trash")
            nkeymap("E", api.tree.expand_all, "Expand All")
            nkeymap("e", api.fs.rename_basename, "Rename: Basename")
            nkeymap("]e", api.node.navigate.diagnostics.next, "Next Diagnostic")
            nkeymap("[e", api.node.navigate.diagnostics.prev, "Prev Diagnostic")
            nkeymap("F", api.live_filter.clear, "Live Filter: Clear")
            nkeymap("f", api.live_filter.start, "Live Filter: Start")
            nkeymap("?", api.tree.toggle_help, "Help")
            nkeymap("gy", api.fs.copy.absolute_path, "Copy Absolute Path")
            nkeymap("ge", api.fs.copy.basename, "Copy Basename")
            nkeymap("H", api.tree.toggle_hidden_filter, "Toggle Filter: Dotfiles")
            nkeymap("I", api.tree.toggle_gitignore_filter, "Toggle Filter: Git Ignore")
            -- nkeymap("J",              api.node.navigate.sibling.last,     "Last Sibling")
            -- nkeymap("K",              api.node.navigate.sibling.first,    "First Sibling")
            nkeymap("L", api.node.open.toggle_group_empty, "Toggle Group Empty")
            nkeymap("M", api.tree.toggle_no_bookmark_filter, "Toggle Filter: No Bookmark")
            nkeymap("m", api.marks.toggle, "Toggle Bookmark")
            nkeymap("o", api.node.open.edit, "Open")
            nkeymap("O", api.node.open.no_window_picker, "Open: No Window Picker")
            nkeymap("p", api.fs.paste, "Paste")
            nkeymap("P", api.node.navigate.parent, "Parent Directory")
            -- nkeymap("q",              api.tree.close,                     "Close")
            nkeymap("r", api.fs.rename, "Rename")
            nkeymap("R", api.tree.reload, "Refresh")
            nkeymap("s", api.node.run.system, "Run System")
            nkeymap("S", api.tree.search_node, "Search")
            nkeymap("u", api.fs.rename_full, "Rename: Full Path")
            nkeymap("m", api.fs.rename_full, "Rename: Full Path")
            nkeymap("U", api.tree.toggle_custom_filter, "Toggle Filter: Hidden")
            nkeymap("W", api.tree.collapse_all, "Collapse")
            nkeymap("x", api.fs.cut, "Cut")
            nkeymap("y", api.fs.copy.filename, "Copy Name")
            nkeymap("Y", api.fs.copy.relative_path, "Copy Relative Path")
            nkeymap("<2-LeftMouse>", api.node.open.edit, "Open")
            nkeymap("<2-RightMouse>", api.tree.change_root_to_node, "CD")
        end,
        view = {
            signcolumn = "auto",
        },
    },
}
