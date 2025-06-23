-- ref: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

local common = require("plugins.heirline.common")

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")



local treesitter_hl = require("vim.treesitter.highlighter")

local WinSeparator = {
    provider = "│",
    hl = "WinSeparator",
}


local TabLineOffset = {
    condition = function(self)
        local win = vim.api.nvim_tabpage_list_wins(0)[1]
        local bufnr = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        self.winid = win

        if filetype == "NvimTree" then
            self.title = "NvimTree"
        elseif filetype == "OverseerList" then
            self.title = "Overseer"
        else
            return false
        end

        return true
    end,

    {
        provider = function(self)
            local title = self.title
            local width = vim.api.nvim_win_get_width(self.winid)
            local pad = math.ceil((width - #title) / 2)
            return string.rep(" ", pad) .. title .. string.rep(" ", pad)
        end,

        hl = function(self)
            if vim.api.nvim_get_current_win() == self.winid then
                return {
                    fg = "green",
                    bold = true,
                }
            else
                return {
                    fg = utils.get_highlight("BufferTabpageFill").fg,
                }
            end
        end,
    },
    WinSeparator,
}


local PyVenvInfo = {
    update    = { 'LspAttach', 'LspDetach', "BufEnter" },
    condition = conditions.lsp_attached,

    init      = function(self)
        self.py_venv = require('auto-venv').get_python_venv(self.bufnr,
            { disable_notifications = true, full_version = true })
    end,

    hl        = function(self)
        local is_builtin = self.py_venv == nil or self.py_venv.name == "<system>"
        return {
            fg = is_builtin and "red" or "green",
            bold = true,
        }
    end,

    provider  = function(self)
        return self.py_venv ~= nil and ' ' .. (self.py_venv.name)
    end,
}

local LSPActive = {
    update   = { 'LspAttach', 'LspDetach', "BufEnter" },

    init     = function(self)
        self.py_venv = require('auto-venv').get_python_venv(self.bufnr,
            { disable_notifications = true, full_version = true })
        self.clients = {}

        for _, client in pairs(vim.lsp.get_clients({ bufnr = self.bufnr })) do
            local client_info = {
                name = client.name,
                sources = {},
            }

            table.insert(self.clients, client_info)
        end

        self.conform_formatters = require('conform').list_formatters(self.bufnr)
        self.linter_names = require('lint')._resolve_linter_by_ft(self.filetype)
    end,
    provider = " ",
    hl       = function(self)
        return {
            fg = #self.clients > 0 and "green" or "red",
            bold = true,
        }
    end,

    on_click = {
        callback = function(self)
            local info_strings = {}

            for _, client in pairs(self.clients) do
                local info_string = "* `" .. client.name .. '`'

                for _, source in pairs(client.sources) do
                    local source_string = "`" .. source.name .. "`"

                    if #source.methods >= 1 then
                        local methods_string = table.concat(source.methods, ', ')

                        source_string = source_string .. " (" .. methods_string .. ")"
                    end

                    if not source.is_available then
                        source_string = source_string .. " **DISABLED**"
                    end

                    if source.extra_info then
                        source_string = source_string .. ": " .. source.extra_info
                    end

                    info_string = info_string .. "\n    " .. source_string
                end

                table.insert(info_strings, info_string)
            end

            if #self.linter_names > 0 then
                table.insert(info_strings, "\nLinters:\n")

                for _, linter_name in pairs(self.linter_names) do
                    local linter = require('lint').linters[linter_name]

                    local linter_cmd
                    if type(linter.cmd) == "function" then
                        linter_cmd = linter.cmd()
                    else
                        linter_cmd = linter.cmd
                    end

                    local item = "* `" .. linter_name .. "`"

                    if not linter_cmd or (not require("utils.shell").executable_exists(linter_cmd)) then
                        item = "* ~~`" .. linter_name .. "`~~" .. " **(NOT AVAILABLE)**"
                    elseif self.py_venv ~= nil and linter_cmd:find(self.py_venv.bin_path, 1, true) == 1 then
                        item = item .. " "
                    end

                    table.insert(info_strings, item)
                end
            end

            if #self.conform_formatters > 0 then
                table.insert(info_strings, "\nFormatters:\n")

                for _, formatter in pairs(self.conform_formatters) do
                    local item = "* `" .. formatter.name .. "`"

                    if not formatter.available then
                        item = item .. " **NOT AVAILABLE**"
                    elseif self.py_venv ~= nil and formatter.command:find(self.py_venv.bin_path, 1, true) == 1 then
                        item = item .. " "
                    end

                    table.insert(info_strings, item)
                end
            end

            if self.py_venv ~= nil then
                local info_string = 'venv: `' .. self.py_venv.name .. '`'

                if self.py_venv.venv_manager_name ~= nil then
                    info_string = info_string .. " via **" .. self.py_venv.venv_manager_name .. "**"
                end

                if self.py_venv.python_version ~= nil then
                    info_string = info_string .. " (" .. self.py_venv.python_version .. ")"
                end

                table.insert(info_strings, "")
                table.insert(info_strings, info_string)
            end

            require("utils.markdown").notify('Running LSP Clients for buffer ' .. self.bufnr, info_strings)
        end,
        update = true,
        name = 'lsp_active_on_click',
    },
}

local function OverseerTasksForStatus(status)
    return {
        condition = function(self)
            return self.tasks[status]
        end,
        provider = function(self)
            return string.format("%s %d", self.symbols[status], #self.tasks[status])
        end,
        hl = function(self)
            return {
                fg = utils.get_highlight(string.format("Overseer%s", status)).fg,
            }
        end,
    }
end

local Overseer = {
    static    = {
        symbols = {
            ["CANCELED"] = "",
            ["FAILURE"] = "󰅚",
            ["SUCCESS"] = "󰄴",
            ["RUNNING"] = "󰑮",
        },
    },

    condition = function(self)
        return package.loaded.overseer
    end,

    init      = function(self)
        local tasks = require("overseer.task_list").list_tasks({ unique = true })
        local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
        self.tasks = tasks_by_status
    end,

    provider  = " ",
    hl        = { fg = "aqua" },

    on_click  = {
        callback = function(_, minwid)
            vim.schedule(vim.cmd.OverseerToggle)
        end,
        name = "heirline_overseer_on_click",
    },

    common.Lpad(OverseerTasksForStatus("CANCELED")),
    common.Lpad(OverseerTasksForStatus("RUNNING")),
    common.Lpad(OverseerTasksForStatus("SUCCESS")),
    common.Lpad(OverseerTasksForStatus("FAILURE")),
    common.Lpad({ provider = "│" }),
}

local TabPageName = {
    common.FileIcon,
    {
        common.FileName,
        hl = function(self)
            if self.is_active then
                return { fg = "green", bold = true }
            else
                return { fg = utils.get_highlight("BufferTabpageFill").fg }
            end
        end,
    },

    on_click = {
        callback = function(_, minwid)
            vim.schedule(function()
                vim.api.nvim_set_current_tabpage(minwid)
                vim.cmd.redrawtabline()
            end)
        end,
        minwid = function(self)
            return self.tabpage
        end,
        name = "heirline_tabline_select_tab_callback",
    },
}

local CloseTabBtnBlock = {
    condition = function(self)
        return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    {
        common.Space,
        {
            provider = "x",
            on_click = {
                callback = function(_, minwid)
                    vim.schedule(function()
                        vim.cmd.tabclose(minwid)
                        vim.cmd.redrawtabline()
                    end)
                end,
                minwid = function(self)
                    return self.tabnr
                end,
                name = "heirline_tabline_close_tab_callback",
            },
        }
    }
}

local TabPageBlock = utils.insert(common.CommonFileBlock,
    TabPageName,
    common.FileFlags,
    CloseTabBtnBlock
)


local TabPages = {
    utils.make_tablist(utils.surround({ " ", " " }, "bg", { TabPageBlock })),
}


local TreeSitterBlock = {
    init      = function(self)
        local win = vim.api.nvim_tabpage_list_wins(0)[1]
        local bufnr = vim.api.nvim_win_get_buf(win)
        self.is_active = treesitter_hl.active[bufnr] ~= nil
    end,
    condition = function(self)
        return not self.is_active
    end,
    provider  = " ",
    hl        = {
        fg = "red",
    }
}

return {
    TabLineOffset,
    common.Lpad(Overseer),
    TabPages,
    common.Align,
    common.Rpad(utils.insert(common.CurrentTabFileBlock, PyVenvInfo)),
    utils.insert(common.CurrentTabFileBlock, LSPActive),
    TreeSitterBlock,
    hl = { bg = "bg" }
}
