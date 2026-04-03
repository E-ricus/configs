return {
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
  end,
  dependencies = { "nvim-treesitter/nvim-treesitter-context", "nvim-treesitter/nvim-treesitter-textobjects" },
}
