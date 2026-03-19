return {
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "algmyr/vcsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("vcsigns").setup({
        -- target_commit = 1 is good for jj new+squash flow
        -- 0 = working copy parent (default for git)
        -- 1 = parent of working copy parent (good for jj)
        target_commit = 1,
      })

      local function map(mode, lhs, rhs, desc, opts)
        local options = { noremap = true, silent = true, desc = desc }
        if opts then
          options = vim.tbl_extend("force", options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
      end

      -- Hunk navigation (same keys as old gitsigns)
      map("n", "]g", function()
        require("vcsigns.actions").hunk_next(0, vim.v.count1)
      end, "Next hunk")
      map("n", "[g", function()
        require("vcsigns.actions").hunk_prev(0, vim.v.count1)
      end, "Prev hunk")

      -- Diff target navigation (move between commits)
      map("n", "[r", function()
        require("vcsigns.actions").target_older_commit(0, vim.v.count1)
      end, "Diff target older commit")
      map("n", "]r", function()
        require("vcsigns.actions").target_newer_commit(0, vim.v.count1)
      end, "Diff target newer commit")

      -- Hunk actions
      map("n", "<leader>hu", function()
        require("vcsigns.actions").hunk_undo(0)
      end, "Undo hunk under cursor")
      map("v", "<leader>hu", function()
        require("vcsigns.actions").hunk_undo(0)
      end, "Undo hunks in range")
      map("n", "<leader>hd", function()
        require("vcsigns.actions").toggle_hunk_diff(0)
      end, "Toggle inline hunk diff")
      map("n", "<leader>hf", function()
        require("vcsigns.fold").toggle(0)
      end, "Fold outside hunks")
    end,
  },
  {
    "nicolasgb/jj.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      require("jj").setup({
        diff = {
          backend = "native",
        },
        cmd = {
          describe = {
            editor = {
              type = "buffer",
              keymaps = {
                close = { "q", "<Esc>", "<C-c>" },
              },
            },
          },
        },
      })

      local cmd = require("jj.cmd")
      local diff = require("jj.diff")
      local annotate = require("jj.annotate")

      -- Core jj commands under <leader>j
      vim.keymap.set("n", "<leader>jl", cmd.log, { desc = "JJ log" })
      vim.keymap.set("n", "<leader>jL", function()
        cmd.log({ revisions = "'all()'" })
      end, { desc = "JJ log all" })
      vim.keymap.set("n", "<leader>js", cmd.status, { desc = "JJ status" })
      vim.keymap.set("n", "<leader>jd", cmd.describe, { desc = "JJ describe" })
      vim.keymap.set("n", "<leader>jn", cmd.new, { desc = "JJ new" })
      vim.keymap.set("n", "<leader>je", cmd.edit, { desc = "JJ edit" })
      vim.keymap.set("n", "<leader>jq", cmd.squash, { desc = "JJ squash" })
      vim.keymap.set("n", "<leader>jr", cmd.rebase, { desc = "JJ rebase" })
      vim.keymap.set("n", "<leader>ja", cmd.abandon, { desc = "JJ abandon" })
      vim.keymap.set("n", "<leader>ju", cmd.undo, { desc = "JJ undo" })
      vim.keymap.set("n", "<leader>jy", cmd.redo, { desc = "JJ redo" })
      vim.keymap.set("n", "<leader>jc", cmd.commit, { desc = "JJ commit" })

      -- Fetch / Push
      vim.keymap.set("n", "<leader>jf", cmd.fetch, { desc = "JJ fetch" })
      vim.keymap.set("n", "<leader>jp", cmd.push, { desc = "JJ push" })
      vim.keymap.set("n", "<leader>jo", cmd.open_pr, { desc = "JJ open PR" })
      vim.keymap.set("n", "<leader>jO", function()
        cmd.open_pr({ list_bookmarks = true })
      end, { desc = "JJ open PR (list bookmarks)" })

      -- Bookmarks
      vim.keymap.set("n", "<leader>jbc", cmd.bookmark_create, { desc = "JJ bookmark create" })
      vim.keymap.set("n", "<leader>jbd", cmd.bookmark_delete, { desc = "JJ bookmark delete" })
      vim.keymap.set("n", "<leader>jbm", cmd.bookmark_move, { desc = "JJ bookmark move" })

      -- Diff
      vim.keymap.set("n", "<leader>jD", function()
        diff.open_vdiff()
      end, { desc = "JJ diff current buffer" })

      -- Annotate / Blame
      vim.keymap.set("n", "<leader>jA", annotate.file, { desc = "JJ annotate file" })
      vim.keymap.set("n", "<leader>jal", annotate.line, { desc = "JJ annotate line" })

      -- Browse
      vim.keymap.set("n", "<leader>jB", "<cmd>Jbrowse<cr>", { desc = "JJ browse file on remote" })
      vim.keymap.set("v", "<leader>jB", "<cmd>Jbrowse<cr>", { desc = "JJ browse selection on remote" })
    end,
  },
}
