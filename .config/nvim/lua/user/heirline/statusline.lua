local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local common = require("user.heirline.common")

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

local BufferNumber = {
    provider = function(self)
        return self.bufnr .. ' '
    end,
}

RelativeFilePathBlock = utils.insert(common.CurrentTabFileBlock,
    common.Space,
    utils.insert(common.FileIcon, BufferNumber),
    common.RelativeFilePath,
    common.FileFlags,
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
    hl = {
        fg = 'green',
    }
}
local BufferType = {
    -- TODO: Add the icon with a seperate compoennt for it (using the one in the filename)
    provider = function()
        return vim.bo.buftype
    end,
    hl = {
        fg = 'blue',
    }
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

    common.Space,
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
    common.Space,
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


return {
    hl = { bg = "bg" },

    VimMode,
    GitInfo,
    Diagnostics,
    common.Lpad(MacroRecording),
    RelativeFilePathBlock,

    common.Align,

    common.Rpad(Project),
    common.Rpad(FileEncoding),
    common.Rpad(FileFormat),
    common.Rpad(FileType),
    common.Rpad(BufferType),
    common.Rpad(Ruler),
    common.Rpad(ScrollBar),
}
