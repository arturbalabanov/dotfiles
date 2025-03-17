local my_utils = require("user.utils")

vim.api.nvim_create_user_command('Redir', function(ctx)
    local result = vim.api.nvim_exec2(ctx.args, { output = true })
    my_utils.show_in_split(result.output)
end, { nargs = '+', complete = 'command' })

vim.api.nvim_create_user_command('P', function(ctx)
    local template = [[
        local my_utils = require("user.utils")

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
end, { nargs = '+', complete = 'lua' })

vim.api.nvim_create_user_command("ToggleLSPFormatting", function(ctx)
    local context
    local enabled_str

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
