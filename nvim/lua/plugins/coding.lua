return {
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  -- Editor enhancements
  { "tpope/vim-surround", event = "VeryLazy" },
  { "lukas-reineke/indent-blankline.nvim", event = "VeryLazy" },
  { "andymass/vim-matchup", event = "BufReadPre" },
  {
    "shortcuts/no-neck-pain.nvim",
    event = "VeryLazy",
    version = "*",
    init = function()
      -- Start with it
      -- vim.cmd "NoNeckPain"
    end,
  },

  -- Langs Enhacement
  "vim-test/vim-test",
  { "ziglang/zig.vim", event = "BufReadPre *.zig" },
  { "ChrisWellsWood/roc.vim", event = "BufReadPre *.roc" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    ft = "markdown",
  },
  {
    "folke/trouble.nvim",
    opts = {
      focus = true,
    },
    cmd = "Trouble",
    init = function()
      -- overwrites native quickfix to use trouble
      vim.api.nvim_create_autocmd("BufRead", {
        callback = function(ev)
          if vim.bo[ev.buf].buftype == "quickfix" then
            vim.schedule(function()
              vim.cmd([[cclose]])
              vim.cmd([[Trouble qflist open]])
            end)
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>dw",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>db",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>ts",
        "<cmd>Trouble symbols toggle<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>tl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
}
