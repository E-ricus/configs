return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      -- v1.0: configs.setup() is gone; highlighting is neovim built-in
      require("nvim-treesitter.install").install({
        "c",
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
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = { "*.c3", "*.c3i" },
        callback = function()
          vim.treesitter.start()
        end,
        desc = "Start treesitter for c3 files",
      })
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter-context", "nvim-treesitter/nvim-treesitter-textobjects" },
  },
}
