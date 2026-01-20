return {
  {
    -- Generic semantic token customization for all themes
    "semantic-highlights",
    dir = vim.fn.stdpath("config"),
    name = "semantic-highlights",
    lazy = false,
    priority = 999, -- Load right after themes (which have priority 1000)
    config = function()
      -- Disable grayed out inactive code regions (for all LSPs)
      local function disable_inactive_regions()
        vim.api.nvim_set_hl(0, "@lsp.mod.inactive", { link = "Normal" })
        vim.api.nvim_set_hl(0, "@lsp.mod.unused", { link = "Normal" })
        -- clang makes the semantic token a comment
        vim.api.nvim_set_hl(0, "@lsp.type.comment.c", {})
      end

      disable_inactive_regions()

      -- Set up autocmd to reapply after colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = disable_inactive_regions,
      })
    end,
  },
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
