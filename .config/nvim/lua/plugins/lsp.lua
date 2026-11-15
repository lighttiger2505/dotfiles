return {
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
            {
                "nvimdev/lspsaga.nvim",
                config = function()
                    require("lspsaga").setup({
                        symbol_in_winbar = {
                            enable = false,
                        },
                        ui = {
                            code_action = "",
                        },
                    })
                end,
            },
            { "saghen/blink.cmp" },
        },
        cond = function()
            -- ignore filetype markdown
            return vim.bo.filetype ~= "markdown"
        end,
        opts = {
            servers = {
                gopls = {
                    settings = {
                        gopls = {
                            ["Formatting.local"] = "github.com/MobilityTechnologies",
                        },
                    },
                },
                tsc = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                            format = {
                                enable = true,
                                defaultConfig = {
                                    indent_style = "space",
                                    indent_size = "4",
                                },
                            },
                        },
                    },
                },
                sqls = {
                    cmd = {
                        "sqls",
                        "-log",
                        os.getenv("HOME") .. "/sqls.log",
                        "-config",
                        os.getenv("HOME") .. "/.config/sqls/config.yml",
                    },
                    -- cmd = { 'sqls', '-config', os.getenv("HOME") .. '/.config/sqls/config.yml' },
                    settings = {
                        sqls = {
                            connections = {
                                {
                                    driver = "mysql",
                                    dataSourceName = "root:root@tcp(127.0.0.1:13306)/world",
                                },
                                {
                                    driver = "postgresql",
                                    dataSourceName = "host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable",
                                },
                            },
                        },
                    },
                },
                biome = {},
                jsonls = {},
                copilot = {},
            },
        },
        config = function(_, opts)
            -- Set NVIM_DISABLE_COPILOT=1 on machines without GitHub Copilot access
            if vim.env.NVIM_DISABLE_COPILOT then
                opts.servers.copilot = nil
            end

            for server, config in pairs(opts.servers) do
                config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
                vim.lsp.config[server] = config
            end

            local servers = vim.tbl_keys(opts.servers)
            vim.lsp.enable(servers)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("my.lsp", {}),
                callback = function(args)
                    local buf = args.buf
                    -- builtin lsp
                    local optWithDesc = function(desc)
                        local result = { noremap = true, silent = true, buffer = buf, desc = desc }
                        return result
                    end
                    vim.keymap.set("n", "<LocalLeader>n", vim.lsp.buf.references, optWithDesc("LSP References"))
                    vim.keymap.set("n", "<LocalLeader>R", vim.lsp.buf.rename, optWithDesc("LSP Rename"))
                    vim.keymap.set("n", "<LocalLeader>i", vim.lsp.buf.implementation, optWithDesc("LSP Implementation"))
                    vim.keymap.set("i", "<C-l>", vim.lsp.buf.signature_help, optWithDesc("LSP Signature Help"))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, optWithDesc("LSP Hover"))
                    vim.keymap.set("n", "<LocalLeader>e", vim.diagnostic.open_float, optWithDesc("Diagnostic Float"))
                    vim.keymap.set("n", "<LocalLeader>d", vim.diagnostic.setloclist, optWithDesc("Diagnostic List"))
                    -- lsp saga
                    vim.keymap.set(
                        "n",
                        "<LocalLeader>a",
                        "<cmd>Lspsaga code_action<CR>",
                        optWithDesc("LSP Code Action")
                    )
                    vim.keymap.set(
                        "i",
                        "<LocalLeader>a",
                        "<cmd>Lspsaga code_action<CR>",
                        optWithDesc("LSP Code Action")
                    )
                    vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", optWithDesc("Prev Diagnostic"))
                    vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", optWithDesc("Next Diagnostic"))
                    vim.keymap.set("n", "<C-]>", "<cmd>Lspsaga goto_definition<CR>", optWithDesc("Goto Definition"))
                end,
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end,
    },

    {
        "j-hui/fidget.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        event = "LspAttach",
        config = function()
            require("fidget").setup()
        end,
    },

    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("aerial").setup({
                backends = { "lsp", "treesitter", "markdown" },
            })
            require("telescope").load_extension("aerial")
        end,
        keys = {
            { "]]", "<cmd>AerialNext<CR>", mode = "n", desc = "Aerial Jump prev symbol" },
            { "[[", "<cmd>AerialPrev<CR>", mode = "n", desc = "Aerial Jump next symbol" },
            { "<Leader>o", "<cmd>AerialToggle!<CR>", mode = "n", desc = "Aerial Open symbol list" },
            { "<Space>o", "<Cmd>Telescope aerial<CR>", mode = "n", desc = "Aerial Find symbol list" },
        },
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<LocalLeader>f",
                function()
                    require("conform").format({ async = true, lsp_format = "first" })
                end,
                mode = "n",
                desc = "Conform Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "biome", "prettier", stop_after_first = true },
                typescript = { "biome", "prettier", stop_after_first = true },
                typescriptreact = { "biome", "prettier", stop_after_first = true },
                json = { "jq" },
                go = { "goimports", "gofmt", "golangci-lint", stop_after_first = false },
            },
            format_on_save = function(bufnr)
                -- disable filetypes
                local disable_filetypes = { "json" }
                local ft = vim.bo[bufnr].filetype
                if vim.tbl_contains(disable_filetypes, ft) then
                    return nil -- nilを返すと無効化
                end
                return {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                }
            end,
        },
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePost" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                javascript = { "oxlint", "biomejs", "eslint" },
                typescript = { "oxlint", "biomejs", "eslint" },
                typescriptreact = { "oxlint", "biomejs", "eslint" },
                json = { "jsonlint" },
                proto = { "buf_lint" },
                make = { "checkmake" },
                zsh = { "zsh" },
                lua = { "luacheck" },
                go = { "golangcilint" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint(nil, { ignore_errors = true })
                end,
            })
        end,
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                "lazy.nvim",
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        config = function()
            require("tiny-inline-diagnostic").setup()
            -- Disable Neovim's default virtual text diagnostics
            vim.diagnostic.config({ virtual_text = false })
        end,
    },
}
