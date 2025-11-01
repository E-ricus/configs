return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  enabled = false,
  opts = function(_, _)
    local fzf = require("fzf-lua")
    local config = fzf.config

    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-h>"] = "toggle-preview"
  end,
  keys = {
    { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "List Buffers" },
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "List Buffers" },
    { "<leader>ft", "<cmd>FzfLua filetypes<cr>", desc = "Search files by extension" },
    { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Show git branches" },
    { "<leader>fc", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
    { "<leader>fg", "<cmd>FzfLua grep_project<cr>", desc = "Grep word in project" },
    { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
    { "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Open quickfix" },
    { "gi", "<cmd>FzfLua lsp_implementations<cr>", desc = "LSP Implementations" },
    { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "LSP references" },
    { "<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "LSP document symbols" },
    { "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "LSP workspace symbols" },
  },
}
