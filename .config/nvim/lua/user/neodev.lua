local status_ok, neodev = pcall(require, "neodev")
if not status_ok then
    return
end

neodev.setup({
    library = { plugins = { "neotest" }, types = true },
})
