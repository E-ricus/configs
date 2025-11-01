return {
  {
    "catppuccin/nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "sainnhe/everforest",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme everforest")
    end,
  },
  {
    "sainnhe/gruvbox-material",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox-material")
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
    end,
    opts = ...,
  },
  {
    "folke/tokyonight.nvim",
    enabled = false,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "EdenEast/nightfox.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          styles = {
            types = "NONE",
            numbers = "NONE",
            strings = "NONE",
            comments = "italic",
            keywords = "bold,italic",
            constants = "NONE",
            functions = "italic",
            operators = "NONE",
            variables = "NONE",
            conditionals = "italic",
            virtual_text = "NONE",
          },
        },
      })
      vim.cmd("colorscheme nordfox")
    end,
  },
}
