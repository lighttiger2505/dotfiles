return {
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
            config = function()
                require("ts_context_commentstring").setup({
                    enable_autocmd = false,
                })
            end,
        },
        event = "VeryLazy",
        config = function()
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    {
        "mattn/sonictemplate-vim",
        cmd = { "Template" },
    },

    {
        "nanotee/sqls.nvim",
        ft = { "sql" },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
        "mattn/vim-sqlfmt",
        ft = { "sql" },
    },

    {
        "pmouraguedes/sql-ghosty.nvim",
        ft = { "sql" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
    },

    {
        "nicwest/vim-camelsnek",
        cmd = {
            "Snek",
            "Camel",
            "CamelB",
            "Kebab",
            "Screm",
        },
    },

    {
        "gregorias/coerce.nvim",
        tag = "v4.1.0",
        event = "VeryLazy",
        config = function()
            require("coerce").setup({
                default_mode_mask = {
                    normal_mode = true,
                    motion_mode = false,
                    visual_mode = false,
                },
            })
        end,
    },

    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                lsp_codelens = false,
            })
        end,
        init = function()
            local kmopt = { noremap = true, silent = true }
            vim.keymap.set("n", "<LocalLeader>b", "<Cmd>GoBuild<CR>", kmopt)
            vim.keymap.set("n", "<LocalLeader>m", "<Cmd>GoImports<CR>", kmopt)
            vim.keymap.set("n", "<LocalLeader>t", "<Cmd>GoAlt<CR>", kmopt)
        end,
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()',
    },

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        opts = {
            signs = true,
        },
    },

    {
        "sheerun/vim-polyglot",
        event = "VeryLazy",
    },

    -- {
    --     "cbochs/grapple.nvim",
    --     config = function()
    --         local telescope = require("telescope")
    --         telescope.load_extension("grapple")
    --         require("grapple").setup({
    --             scope = "git_branch",
    --             icons = true,
    --         })
    --     end,
    --     keys = {
    --         {
    --             "<Space>m",
    --             "<Cmd>Telescope grapple tags<CR>",
    --             mode = "n",
    --             desc = "Telescope Find grapple tags",
    --         },
    --         { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    --     },
    -- },
}
