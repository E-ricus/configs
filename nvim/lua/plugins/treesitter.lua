return {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "go", "lua", "python", "rust", "typescript", "comment", "zig" },
      auto_install = true,
      highlight = { enable = true },
      folds = { enable = true },
      indent = { enable = false },
      matchup = { enable = false },
    })
  end,
  dependencies = { "nvim-treesitter/nvim-treesitter-context", "nvim-treesitter/nvim-treesitter-textobjects" },
}
