return {
    {
        "ixru/nvim-markdown",
        ft = { "markdown" },
        init = function()
            local group_name = "PluginNvimMarkdown"
            vim.api.nvim_create_augroup(group_name, { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = group_name,
                pattern = { "markdown" },
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local bufopts = { noremap = true, silent = true, buffer = bufnr }
                    vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader", bufopts)
                    vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader", bufopts)
                    vim.keymap.set("n", "O", "<Plug>Markdown_NewLineAbove", bufopts)
                    vim.keymap.set("n", "o", "<Plug>Markdown_NewLineBelow", bufopts)
                    vim.keymap.set("i", "<Enter>", "<Plug>Markdown_NewLineBelow", bufopts)
                    vim.keymap.set("i", "<C-k>", "<Plug>Markdown_CreateLink", bufopts)
                    vim.keymap.set("x", "<C-k>", "<Plug>Markdown_CreateLink", bufopts)
                    vim.keymap.set("n", "<LocalLeader>c", "<Plug>Markdown_Checkbox", bufopts)
                end,
            })
        end,
        config = function()
            vim.g.vim_markdown_no_default_key_mappings = 1
            vim.g.vim_markdown_conceal = 1
            vim.g.vim_markdown_toc_autofit = 1
        end,
    },

    {
        "dhruvasagar/vim-table-mode",
        ft = { "markdown" },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            code = {
                language_icon = true,
                language_name = true,
                border = "thick",
            },
            html = {
                comment = {
                    conceal = false,
                },
            },
            anti_conceal = {
                disabled_modes = { "n" },
            },
            win_options = {
                concealcursor = { rendered = "nc" },
            },
        },
        config = function(_, opts)
            local rm = require("render-markdown")
            rm.setup(opts)
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    rm.disable()
                end,
            })
        end,
        keys = {
            {
                "<leader>m",
                "<Cmd>lua require('render-markdown').toggle()<CR>",
                mode = "n",
                desc = "RenderMarkdown toggle",
            },
        },
    },

    {
        "epwalsh/obsidian.nvim",
        cmd = {
            "ObsidianNew",
            "ObsidianToday",
            "ObsidianQuickSwitch",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            notes_subdir = "01_Index",
            new_notes_location = "01_Index",
            note_id_func = function(title)
                -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                -- In this case a note with the title 'My new note' will be given an ID that looks
                -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                local suffix = ""
                if title ~= nil then
                    -- If title is given, transform it into valid file name.
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                else
                    -- If title is nil, just add 4 random uppercase letters to the suffix.
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                return tostring(os.time()) .. "-" .. suffix
            end,
            ui = {
                enable = false,
            },
            workspaces = {
                {
                    name = "Notes",
                    path = "~/vaults/01_Index",
                },
                {
                    name = "Work",
                    path = "~/vaults/02_Work",
                },
                {
                    name = "Private",
                    path = "~/vaults/03_Private",
                },
                {
                    name = "Areas",
                    path = "~/vaults/04_Areas",
                },
                {
                    name = "Archive",
                    path = "~/vaults/05_Archive",
                },
            },
            mappings = {},
            daily_notes = {
                folder = "06_Dailies",
                date_format = "%Y-%m-%d",
                alias_format = "%B %-d, %Y",
                default_tags = { "daily-notes" },
                template = nil,
            },
        },
        keys = {
            { "<Space>v", "<Cmd>ObsidianQuickSwitch<CR>", mode = "n", desc = "Obsidian Quick Switch" },
        },
    },

    {
        "previm/previm",
        cmd = {
            "PrevimOpen",
        },
    },

    {
        "arto-app/arto.vim",
        cmd = {
            "Arto",
        },
    },
}
