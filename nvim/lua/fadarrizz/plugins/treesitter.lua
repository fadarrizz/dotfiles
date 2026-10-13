return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      vim.filetype.add({ extension = { avsc = "json" } })

      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local parsers = require("nvim-treesitter.parsers")

          parsers.blade = {
            install_info = {
              url = "https://github.com/EmranMR/tree-sitter-blade",
              files = { "src/parser.c" },
              branch = "main",
            },
          }

          parsers.klog = {
            install_info = {
              url = "https://github.com/Ansimorph/tree-sitter-klog",
              files = { "src/parser.c", "src/scanner.c" },
              branch = "main",
            },
          }
        end,
      })

      ts.install({
        "vimdoc",
        "php",
        "javascript",
        "c",
        "go",
        "lua",
        "rust",
        "jsdoc",
        "bash",
        "blade",
        "html",
        "kotlin",
        "json",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "php", "javascript", "c", "go", "lua", "rust", "bash", "vimdoc", "blade", "html", "klog", "kotlin", "json" },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "php", "javascript", "c", "go", "lua", "rust", "bash", "blade", "html" },
        callback = function(args)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
      -- "RRethy/nvim-treesitter-endwise",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")

      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "il", function()
        select.select_textobject("@loop.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "al", function()
        select.select_textobject("@loop.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ia", function()
        select.select_textobject("@parameter.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "aa", function()
        select.select_textobject("@parameter.outer", "textobjects")
      end)
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },
}
