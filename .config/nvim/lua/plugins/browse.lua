return {
    {
        "tyru/open-browser.vim",
        event = "VeryLazy",
        config = function()
            local kmopt = { noremap = true, silent = true }
            vim.keymap.set("n", "<Leader>bb", "<Plug>(openbrowser-smart-search)", kmopt)
            vim.keymap.set("x", "<Leader>bb", "<Plug>(openbrowser-smart-search)", kmopt)
        end,
    },
}
