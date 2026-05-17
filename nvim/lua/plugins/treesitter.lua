return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    init = function()
      -- Start treesitter highlighting for any filetype whose parser is
      -- installed.
      --
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          -- Only start if a parser is actually installed/loadable;
          -- otherwise let vim-syntax fallback take over.
          local ok = pcall(vim.treesitter.language.add, lang)
          if ok then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
        desc = "Start treesitter for any installed parser",
      })
    end,
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local parsers = require("nvim-treesitter.parsers")
          parsers.c3.install_info.revision = nil
          parsers.c3.install_info.branch = "main"
          parsers.c3.install_info.queries = "queries"
        end,
        desc = "Track upstream tree-sitter-c3 main + queries",
      })

      require("nvim-treesitter.install").install({
        "c",
        "c3",
        "go",
        "lua",
        "python",
        "rust",
        "typescript",
        "comment",
        "zig",
        "nix",
        "nu",
      })
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter-context", "nvim-treesitter/nvim-treesitter-textobjects" },
  },
}
