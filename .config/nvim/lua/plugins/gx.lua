return {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function()
        vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    submodules = false, -- not needed, submodules are required only for tests
    opts = {
        -- open_browser_app = "os_specific",       -- specify your browser app; default for macOS is "open", Linux "xdg-open" and Windows "powershell.exe"
        -- open_browser_args = { "--background" }, -- specify any arguments, such as --background for macOS' "open".
        handlers = {
            plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
            github = true, -- open github issues
            brewfile = true, -- open Homebrew formulaes and casks
            package_json = true, -- open dependencies from package.json
            search = false, -- search the web/selection on the web if nothing else is found
            go = true, -- open pkg.go.dev from an import statement (uses treesitter)
            jira = { -- custom handler to open Jira tickets (these have higher precedence than builtin handlers)
                name = "jira", -- set name of handler
                handle = function(mode, line, _handler_opts) ---@diagnostic disable-line: unused-local
                    local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
                    local jira_cli_config_path = vim.fn.expand("~/.config/.jira/.config.yml")

                    if not vim.fn.filereadable(jira_cli_config_path) then
                        vim.notify(
                            "gx.nvim: Jira CLI config file not found: " .. jira_cli_config_path,
                            vim.log.levels.ERROR
                        )

                        return nil
                    end

                    -- TODO: Remove dependency on yq
                    local jira_server = vim.fn.system("yq eval '.server' " .. jira_cli_config_path)

                    if vim.v.shell_error ~= 0 then
                        vim.notify(
                            "gx.nvim: Could not read Jira server from config file: " .. jira_cli_config_path,
                            vim.log.levels.ERROR
                        )

                        return nil
                    end

                    -- Remove trailing newline from the server URL
                    jira_server = vim.trim(jira_server)

                    -- TODO: Match the jira issue key with the configured project keys (yq eval '.project.key' ...)
                    if ticket and #ticket < 20 then
                        return jira_server .. "/browse/" .. ticket
                    end
                end,
            },
            -- TODO: Use this recepie but for pyproject.toml / requirements.txt etc. (excl. lockfiles as that's unnecessary)
            --       Including the uv scripts' requirements in the comment section at the very top
            -- rust = {                     -- custom handler to open rust's cargo packages
            --     name = "rust",           -- set name of handler
            --     filetype = { "toml" },   -- you can also set the required filetype for this handler
            --     filename = "Cargo.toml", -- or the necessary filename
            --     handle = function(mode, line, _handler_opts)
            --         local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")
            --
            --         if crate then
            --             return "https://crates.io/crates/" .. crate
            --         end
            --     end,
            -- },
        },
        -- handler_options = {
        --     search_engine = "google",                             -- you can select between google, bing, duckduckgo, ecosia and yandex
        --     search_engine = "https://search.brave.com/search?q=", -- or you can pass in a custom search engine
        --     select_for_search = false,                            -- if your cursor is e.g. on a link, the pattern for the link AND for the word will always match. This disables this behaviour for default so that the link is opened without the select option for the word AND link
        --
        --     git_remotes = { "upstream", "origin" },               -- list of git remotes to search for git issue linking, in priority
        --     git_remotes = function(fname)                         -- you can also pass in a function
        --         if fname:match("myproject") then
        --             return { "mygit" }
        --         end
        --         return { "upstream", "origin" }
        --     end,
        --
        --     git_remote_push = false,          -- use the push url for git issue linking,
        --     git_remote_push = function(fname) -- you can also pass in a function
        --         return fname:match("myproject")
        --     end,
        -- },
    },
}
