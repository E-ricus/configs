return {
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    init = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]g", function()
            if vim.wo.diff then
              return "]g"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Git next change" })

          map("n", "[g", function()
            if vim.wo.diff then
              return "[g"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Git prev change" })
        end,
      })
    end,
  },
}
