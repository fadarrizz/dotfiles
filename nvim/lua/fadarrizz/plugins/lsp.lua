return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-path' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-cmdline' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
        { "rafamadriz/friendly-snippets" },
        { "saadparwaiz1/cmp_luasnip" },
        { "j-hui/fidget.nvim" },
    },
    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require("fidget").setup({})
        require('mason').setup()

        -- NOTE: mason-lspconfig.nvim v2+ removed the `handlers`/
        -- `automatic_installation` options used previously. Installed
        -- servers are now auto-enabled via the native `vim.lsp.enable()`
        -- mechanism, so per-server overrides must go through
        -- `vim.lsp.config()` instead of a `handlers` table.

        -- Apply default capabilities (nvim-cmp completion support) to every server.
        vim.lsp.config('*', {
            capabilities = capabilities,
        })

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            }
        })

        vim.lsp.config('html', {
            filetypes = {
                'antlers.html', 'antlers', 'blade.html.php', 'blade', 'html',
            }
        })

        vim.lsp.config('phpactor', {
            filetypes = { "php", "blade" },
            init_options = {
                ["language_server.diagnostics_on_update"] = false,
                ["language_server.diagnostics_on_open"] = false,
                ["language_server.diagnostics_on_save"] = false,
                ["language_server_phpstan.enabled"] = false,
                ["language_server_psalm.enabled"] = false,
            }
        })

        require('mason-lspconfig').setup({
            ensure_installed = { 'html', 'eslint', 'intelephense', 'rust_analyzer', 'tailwindcss', 'dockerls', 'gopls', 'jsonls', 'bashls', 'pyright', 'kotlin_lsp' },
        })

        require("luasnip.loaders.from_vscode").lazy_load()

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        -- Kotlin LSP (JetBrains, IntelliJ-powered) completion items are
        -- command-only: each item's `textEdit.newText` is empty, so accepting
        -- one via cmp's normal insert pipeline would just dump the label next
        -- to the text you already typed. The real insertion AND the import edit
        -- are performed server-side by executing the item's `command`
        -- (jetbrains.kotlin.completion.apply) via `workspace/executeCommand`.
        --
        -- That command's argument is a per-request SESSION key tied to the
        -- buffer state when the server answered `textDocument/completion`. If
        -- the buffer changed since (you kept typing), an older item's command
        -- inserts at the stale position, leaving your later keystrokes behind
        -- (e.g. "DataIn" -> "DataIntegrityViolationExceptiontaIn").
        --
        -- The fix is this confirm handler:
        -- request one fresh completion at the current cursor and execute the
        -- command of the item matching the label the user selected. The
        -- standard `nvim_lsp` source handles everything else (display,
        -- filtering, incomplete-list refresh), so no custom cmp source is
        -- required. cmp.close() below never inserts, so there is no double
        -- insertion.
        local confirm_default = cmp.mapping.confirm({ select = true })

        local function confirm_kotlin(fallback)
            -- Non-Kotlin buffers use cmp's normal confirm/insert pipeline.
            if vim.bo.filetype ~= 'kotlin' or not cmp.visible() then
                return confirm_default(fallback)
            end

            local entry = cmp.get_selected_entry() or cmp.get_entries()[1]
            local selected = entry and entry.completion_item
            local client = vim.lsp.get_clients({ bufnr = 0, name = 'kotlin_lsp' })[1]
            if not (selected and client) then
                return confirm_default(fallback)
            end

            local want_label = selected.label
            cmp.close()

            local lsp_params = vim.lsp.util.make_position_params(0, client.offset_encoding)
            lsp_params.context = { triggerKind = 1 } -- Invoked
            client:request('textDocument/completion', lsp_params, function(err, response)
                if err or not response then
                    if err then
                        vim.notify(err.message, vim.log.levels.WARN)
                    end
                    return
                end

                local items = response.items or response
                local match
                for _, item in ipairs(items) do
                    if item.label == want_label then
                        match = item
                        break
                    end
                end
                match = match or items[1]
                if not (match and match.command) then
                    return
                end

                client:request('workspace/executeCommand', {
                    command = match.command.command,
                    arguments = match.command.arguments,
                }, function(exec_err)
                    if exec_err then
                        vim.notify(exec_err.message, vim.log.levels.WARN)
                    end
                end, 0)
            end, 0)
        end

        cmp.setup({
            preselect = 'item',
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping(confirm_kotlin, { 'i', 's' }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )
    end
}
