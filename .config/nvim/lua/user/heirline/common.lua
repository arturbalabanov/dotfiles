local conditions = require("heirline.conditions")

M = {}

M.Align = { provider = "%=" }
M.Space = { provider = " " }

function M.Lpad(child)
    return {
        condition = child.condition,
        M.Space,
        child,
    }
end

function M.Rpad(child)
    return {
        condition = child.condition,
        child,
        M.Space,
    }
end

M.CommonFileBlock = {
    init = function(self)
        self.tabnr = vim.api.nvim_tabpage_get_number(self.tabpage)
        self.winnr = vim.api.nvim_tabpage_get_win(self.tabpage)
        self.bufnr = vim.api.nvim_win_get_buf(self.winnr)
        self.filepath = vim.api.nvim_buf_get_name(self.bufnr)
        self.filename = self.filepath == "" and "[No Name]" or vim.fn.fnamemodify(self.filepath, ":t")
        self.filetype = vim.api.nvim_buf_get_option(self.bufnr, 'filetype')
    end,
}

M.CurrentTabFileBlock = {
    init = function(self)
        self.tabpage = vim.api.nvim_get_current_tabpage()
        M.CommonFileBlock.init(self)
    end,
}

M.FileIcon = {
    init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
        return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
        return { fg = self.icon_color }
    end
}

M.FileName = {
    provider = function(self)
        -- escape `%` characters in filenames (e.g. caused by jinja templates in the filename)
        return self.filename:gsub("%%", "%%%%")
    end,
}

M.RelativeFilePath = {
    provider = function(self)
        if self.filepath == "" then
            return "[No Name]"
        end

        -- ~: uses ~ instead of the user's full home dir path
        -- :. makes the path relative to the CWD

        local relative_filepath = vim.fn.fnamemodify(self.filepath, ":~:.")

        -- escape `%` characters in filenames (e.g. caused by jinja templates in the filename)
        relative_filepath = relative_filepath:gsub("%%", "%%%%")

        -- now, if the filepath would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        if not conditions.width_percent_below(#relative_filepath, 0.25) then
            relative_filepath = vim.fn.pathshorten(relative_filepath)
        end

        return relative_filepath
    end,
}

M.BufferModifiedIndicator = {
    condition = function(self)
        return vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    provider = " 雷",
    hl = { fg = "green" },
}

M.BufferLockOrTerminalIndicator = {
    condition = function(self)
        return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
            or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
    end,
    provider = function(self)
        if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
            return "  "
        else
            return " "
        end
    end,
    hl = { fg = "orange" },
}

M.FileFlags = {
    M.BufferModifiedIndicator,
    M.BufferLockOrTerminalIndicator,
}

return M
