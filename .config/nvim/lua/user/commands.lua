local my_utils = require("utils")

vim.api.nvim_create_user_command("Redir", function(ctx)
    local result = vim.api.nvim_exec2(ctx.args, { output = true })
    my_utils.show_in_split(result.output)
end, { nargs = "+", complete = "command" })

vim.api.nvim_create_user_command("P", function(ctx)
    local template = [[
        local my_utils = require("utils")

        local output_str = vim.inspect(%s)

        if string.len(output_str) <= 1000 then
            my_utils.simple_notify(output_str)
        else
            if string.len(output_str) <= 10000 then
                output_str = output_str:sub(1, 10000) .. "..."
            end

            my_utils.show_in_split(output_str, {filetype = "lua"})
        end
    ]]

    loadstring(template:format(ctx.args))()
end, { nargs = "+", complete = "lua" })

vim.api.nvim_create_user_command("ToggleFormatting", function(ctx)
    local context
    local enabled_str

    -- TODO: Use utils.get_var_or_default

    if ctx.bang then
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        context = "globally"

        if vim.g.disable_autoformat then
            enabled_str = "DISABLED"
        else
            enabled_str = "ENABLED"
        end
    else
        if vim.g.disable_autoformat and vim.b.disable_autoformat == nil then
            vim.b.disable_autoformat = true
        else
            vim.b.disable_autoformat = not vim.b.disable_autoformat
        end

        context = "for the current buffer"

        if vim.b.disable_autoformat then
            enabled_str = "DISABLED"
        else
            enabled_str = "ENABLED"
        end
    end

    my_utils.simple_notify("Formatting " .. enabled_str .. " " .. context)
end, {
    desc = "Toggle autoformat on save for the current buffer (or globally when used with !)",
    bang = true,
})

vim.api.nvim_create_user_command("Make", function(params)
    local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)

    if num_subs == 0 then
        cmd = cmd .. " " .. params.args
    end

    local task = require("overseer").new_task({
        cmd = vim.fn.expandcmd(cmd),
        components = {
            { "on_output_summarize", max_lines = 10 },
            { "on_complete_notify" },
            "default",
        },
    })
    task:start()
end, {
    desc = "Run your makeprg as an Overseer task",
    nargs = "*",
    bang = true,
})

vim.api.nvim_create_user_command("PerformanceDebug", function(params)
    -- Memory usage
    -- ref: https://docs.inkdrop.app/examples/troubleshooting-2
    local nsn = vim.api.nvim_get_namespaces()

    local memory_usage = {}

    for name, ns in pairs(nsn) do
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local count = #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
            if count > 0 then
                memory_usage[#memory_usage + 1] = {
                    name = name,
                    buf = buf,
                    count = count,
                    ft = vim.bo[buf].ft,
                }
            end
        end
    end
    table.sort(memory_usage, function(a, b)
        return a.count > b.count
    end)

    vim.print("Memory usage by namespace:")
    vim.print(memory_usage)
end, {
    desc = "Runs performance metrics to help debug slowdowns",
    nargs = "*",
})
