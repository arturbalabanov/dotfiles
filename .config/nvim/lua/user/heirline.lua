-- ref: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

local status_ok, heirline = pcall(require, "heirline")
if not status_ok then
    return
end

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local null_ls = require('null-ls')
local null_ls_sources = require('null-ls.sources')
local Path = require("plenary.path")

local my_utils = require('user.utils')
local py_venv = require('user.py_venv')

local SELECTED_THEME = 'tokyonight_moon'

local themes = {
    common = {
        diag_warn = utils.get_highlight("DiagnosticSignWarn").fg,
        diag_error = utils.get_highlight("DiagnosticSignError").fg,
        diag_hint = utils.get_highlight("DiagnosticSignHint").fg,
        diag_info = utils.get_highlight("DiagnosticSignInfo").fg,
        git_del = utils.get_highlight("diffRemoved").fg,
        git_add = utils.get_highlight("diffAdded").fg,
        git_change = utils.get_highlight("diffChanged").fg,
        buffer_tabpage_fill_fg = utils.get_highlight("BufferTabpageFill").fg
    },
    gruvbox = function()
        return {
            bg = utils.get_highlight("GruvboxBg0").bg,

            red = utils.get_highlight("GruvboxRed").fg,
            green = utils.get_highlight("GruvboxGreen").fg,
            blue = utils.get_highlight("GruvboxBlue").fg,
            orange = utils.get_highlight("GruvboxOrange").fg,
            purple = utils.get_highlight("GruvboxPurple").fg,
            aqua = utils.get_highlight("GruvboxAqua").fg,

            git_info_bg = utils.get_highlight("GruvboxBg1").fg,
            scrollbar_fg = utils.get_highlight("GruvboxAqua").fg,
            scrollbar_bg = utils.get_highlight("GruvboxBg2").fg,
            buffer_tabpage_fill_fg = utils.get_highlight("GruvboxGray").fg
        }
    end,
    tokyonight_moon = function()
        local colors = require("tokyonight.colors").setup()

        return {
            bg = colors.bg,

            red = colors.red,
            green = colors.green,
            blue = colors.blue,
            orange = colors.orange,
            purple = colors.purple,
            aqua = colors.teal,

            git_info_bg = colors.black,
            scrollbar_fg = colors.blue5,
            scrollbar_bg = colors.bg,
        }
    end,
}


------------------------------
-- Common and Utils
------------------------------

local Align = { provider = "%=" }
local Space = { provider = " " }

local WinSeparator = {
    provider = "│",
    hl = "WinSeparator",
}

local function lpad(child)
    return {
        condition = child.condition,
        Space,
        child,
    }
end

local function rpad(child)
    return {
        condition = child.condition,
        child,
        Space,
    }
end

local BufferModifiedIndicator = {
    condition = function(self)
        return vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    provider = " 雷",
    hl = { fg = "green" },
}

local BufferLockOrTerminalIndicator = {
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

------------------------------
-- Statusline Components
------------------------------

local VimMode = {
    init = function(self)
        self.mode = vim.fn.mode(1)
    end,
    static = {
        mode_names = {
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
        },
        mode_colors = {
            n = "red",
            i = "green",
            v = "aqua",
            V = "aqua",
            ["\22"] = "aqua",
            c = "orange",
            s = "purple",
            S = "purple",
            ["\19"] = "purple",
            R = "orange",
            r = "orange",
            ["!"] = "red",
            t = "red",
        }
    },
    provider = function(self)
        return "  " .. self.mode_names[self.mode] .. " "
    end,
    hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.mode_colors[mode], bold = true, }
    end,
    update = {
        "ModeChanged",
        pattern = "*:*",
    },
}

local Diagnostics = {
    condition = conditions.has_diagnostics,

    static = {
        error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
        warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
        info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
        hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
    },

    init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,

    update = { "DiagnosticChanged", "BufEnter" },

    {
        provider = function(self)
            return self.errors > 0 and (" " .. self.error_icon .. self.errors)
        end,
        hl = { fg = "diag_error" },
    },
    {
        provider = function(self)
            return self.warnings > 0 and (" " .. self.warn_icon .. self.warnings)
        end,
        hl = { fg = "diag_warn" },
    },
    {
        provider = function(self)
            return self.info > 0 and (" " .. self.info_icon .. self.info)
        end,
        hl = { fg = "diag_info" },
    },
    {
        provider = function(self)
            return self.hints > 0 and (" " .. self.hint_icon .. self.hints)
        end,
        hl = { fg = "diag_hint" },
    },
}


local FileNameBlock = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
        self.bufnr = vim.api.nvim_get_current_buf()
    end,
}

local FileIcon = {
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

local FileName = {
    provider = function(self)
        -- ~: uses ~ instead of the user's full home dir path
        -- :. makes the path relative to the CWD

        local filename = vim.fn.fnamemodify(self.filename, ":~:.")

        if filename == "" then
            return "[No Name]"
        end

        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        if not conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
        end
        return filename
    end,
}

local FileFlags = {
    BufferModifiedIndicator,
    BufferLockOrTerminalIndicator,
}

local BufferNumber = {
    provider = function(self)
        return self.bufnr .. ' '
    end,
}

FileNameBlock = utils.insert(FileNameBlock,
    Space,
    utils.insert(FileIcon, BufferNumber),
    FileName,
    FileFlags,
    { provider = '%<' } -- this means that the statusline is cut here when there's not enough space
)

local Ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%l:%c %P",
    hl = { bold = true },
}

local ScrollBar = {
    static = {
        sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
        -- Another variant, because the more choice the better.
        -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
    },
    provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "scrollbar_fg", bg = "scrollbar_bg" },
}

local FileType = {
    -- TODO: Add the icon with a seperate compoennt for it (using the one in the filename)
    provider = function()
        return vim.bo.filetype
    end,
}
local FileEncoding = {
    provider = function()
        local encoding = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
        return encoding ~= 'utf-8' and encoding
    end,
    hl = { fg = 'red', bold = true },
}
local FileFormat = {
    provider = function()
        -- TODO: Replace with icon
        local file_format = vim.bo.fileformat
        return file_format ~= 'unix' and file_format
    end,
    hl = { fg = 'red', bold = true },
}

local Project = {
    -- NOTE: If not working, project_nvim uses this event specifically: VimEnter,BufEnter * ++nested
    update   = { 'VimEnter', 'BufEnter' },
    init     = function(self)
        self.project_root = require("project_nvim.project").get_project_root()
    end,
    hl       = { fg = "blue", bold = true },

    flexible = true,

    {
        condition = function(self) return self.project_root ~= nil end,

        provider = function(self)
            return vim.fn.fnamemodify(self.project_root, ":~")
        end,
    },
    {
        condition = function(self) return self.project_root ~= nil end,

        provider = function(self)
            return vim.fn.fnamemodify(self.project_root, ":t")
        end,
    }
}

local GitInfo = {
    condition = conditions.is_git_repo,

    init = function(self)
        local bufnr = vim.api.nvim_get_current_buf()
        self.status_dict = vim.api.nvim_buf_get_var(bufnr, "gitsigns_status_dict")
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    Space,
    {
        provider = function(self)
            return " " .. self.status_dict.head
        end,
        hl = { fg = "orange", bold = true },
    },
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = ""
    },
    {
        provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = "git_add" },
    },
    {
        provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = "git_del" },
    },
    {
        provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = "git_change" },
    },
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = "",
    },
    Space,
    hl = { bg = "git_info_bg" },
}


local MacroRecording = {
    condition = function()
        return vim.fn.reg_recording() ~= ""
    end,
    provider = function()
        return "雷" .. vim.fn.reg_recording()
    end,
    hl = { fg = "red", bold = true },
    update = {
        "RecordingEnter",
        "RecordingLeave",
    }
}

------------------------------
-- Tabline Compontents
------------------------------

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
                    fg = "buffer_tabpage_fill_fg",
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
        local bufnr = vim.api.nvim_get_current_buf()
        self.py_venv = py_venv.get_python_venv(bufnr, { disable_notifications = true })
    end,

    hl        = { fg = "green", bold = true },

    provider  = function(self)
        return self.py_venv ~= nil and ' ' .. (self.py_venv.name or "<system>")
    end,
}

local LSPActive = {
    condition = conditions.lsp_attached,
    update    = { 'LspAttach', 'LspDetach', "BufEnter" },

    init      = function(self)
        self.tabpage = vim.api.nvim_get_current_tabpage()
        self.tabnr = vim.api.nvim_tabpage_get_number(self.tabpage)
        self.winnr = vim.api.nvim_tabpage_get_win(self.tabpage)
        self.bufnr = vim.api.nvim_win_get_buf(self.winnr)
        local filepath = vim.api.nvim_buf_get_name(self.bufnr)
        self.filename = filepath == "" and "[No Name]" or vim.fn.fnamemodify(filepath, ":t")
        self.filetype = vim.api.nvim_buf_get_option(self.bufnr, 'filetype')
        self.py_venv = py_venv.get_python_venv(self.bufnr, { disable_notifications = true })
        self.clients = {}

        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = self.bufnr })) do
            local client_info = {
                name = client.name,
                sources = {},
            }

            if client.name == 'null-ls' or client.name == 'null_ls' then
                local ft_available_sources = null_ls.get_source({ filetype = self.filetype })

                for _, source in pairs(ft_available_sources) do
                    local source_method_names = {}

                    for method_type, enabled in pairs(source.methods) do
                        if enabled then
                            local short_method_type = method_type:gsub("^NULL_LS_(.-)$", "%1"):lower()
                            table.insert(source_method_names, short_method_type)
                        end
                    end

                    local extra_info = nil
                    -- local extra_info = vim.inspect(null_ls_sources.is_available(source))

                    table.insert(client_info.sources, {
                        name = source.name,
                        methods = source_method_names,
                        is_available = null_ls_sources.is_available(source),
                        extra_info = extra_info,
                    })
                end
            end

            table.insert(self.clients, client_info)
        end
    end,
    provider  = " ",

    on_click  = {
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

            if self.py_venv ~= nil then
                local info_string = 'venv: `' .. self.py_venv.name .. '`'

                if self.py_venv.venv_manager_name ~= nil then
                    info_string = info_string .. " via **" .. self.py_venv.venv_manager_name .. "**"
                end

                table.insert(info_strings, "")
                table.insert(info_strings, info_string)
            end

            vim.notify(table.concat(info_strings, '\n'), "info", {
                title = 'Running LSP Clients for buffer ' .. self.bufnr,
                on_open = function(win)
                    local buf = vim.api.nvim_win_get_buf(win)
                    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                end,
            })
        end,
        update = true,
        name = 'lsp_active_on_click',
    },
    hl        = { fg = "green", bold = true },
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

    condition = function()
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

    rpad(OverseerTasksForStatus("CANCELED")),
    rpad(OverseerTasksForStatus("RUNNING")),
    rpad(OverseerTasksForStatus("SUCCESS")),
    rpad(OverseerTasksForStatus("FAILURE")),
}

local TabPageName = {
    FileIcon,
    {
        provider = function(self)
            return self.tabnr .. ": " .. self.filename
        end,
        hl = function(self)
            if self.is_active then
                return { fg = "green", bold = true }
            else
                return { fg = "buffer_tabpage_fill_fg" }
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

local TabPageBlock = {
    init = function(self)
        self.tabnr = vim.api.nvim_tabpage_get_number(self.tabpage)
        self.winnr = vim.api.nvim_tabpage_get_win(self.tabpage)
        self.bufnr = vim.api.nvim_win_get_buf(self.winnr)
        local filepath = vim.api.nvim_buf_get_name(self.bufnr)
        self.filename = filepath == "" and "[No Name]" or vim.fn.fnamemodify(filepath, ":t")
    end,


    TabPageName,
    BufferModifiedIndicator,
    BufferLockOrTerminalIndicator,
    {
        condition = function(self)
            return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
        end,
        { provider = " " },
        {
            provider = "",
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
        },
    },
}


TabPageBlock = utils.surround({ " ", " " }, "bg", { TabPageBlock })
local TabPages = {
    utils.make_tablist(TabPageBlock),
}

------------------------------
-- Lines Config
------------------------------

local StatusLine = {
    hl = { bg = "bg" },

    VimMode,
    GitInfo,
    Diagnostics,
    FileNameBlock,

    Align,
    MacroRecording,
    rpad(Project),
    rpad(FileEncoding),
    rpad(FileFormat),
    rpad(FileType),
    rpad(Ruler),
    rpad(ScrollBar),
}

local TabLine = {
    TabLineOffset,
    TabPages,
    Align,
    rpad(Overseer),
    PyVenvInfo,
    LSPActive,
    hl = { bg = "bg" }
}


heirline.setup({
    statusline = StatusLine,
    tabline = TabLine,
    opts = {
        colors = vim.tbl_deep_extend("keep", themes[SELECTED_THEME](), themes['common']),
    }
})

vim.o.showtabline = 2
vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
