local utils = require("user.utils")

require("nvim-tree").setup({
    view = {
        mappings = {
            list = {
                { key = "t", action = "tabnew" },
                { key = "J", action = "" },
                { key = "K", action = "" },
            },
        },
    }
})


-- Plugin keymaps
utils.nkeymap("<F2>", vim.cmd.NvimTreeToggle)
