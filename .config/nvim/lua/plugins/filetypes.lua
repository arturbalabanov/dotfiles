return {
    { "darfink/vim-plist" },
    {
        "pearofducks/ansible-vim",
        init = function()
            -- NOTE: Removed main.yaml from the list bellow to not conflict with github actions' yaml files.
            --       Maybe there is a better way (e.g. matching against the file directory too) but this is good enough for now
            -- ref: https://github.com/pearofducks/ansible-vim/tree/master?tab=readme-ov-file#gansible_ftdetect_filename_regex

            vim.g.ansible_ftdetect_filename_regex = '\\v(playbook|site|local|requirements)\\.ya?ml$'
        end,
    },
}
