return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 350,
    icons = {
      mappings = true,
    },
    spec = {
      { "<leader>s", group = "Search" },
      { "<leader>f", group = "Finder" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>l", group = "LSP" },
      { "<leader>g", group = "Git" },
      { "<leader>t", group = "Trouble" },
      { "<leader>r", group = "Rust" },
      { "<leader>c", group = "Coding" },
      { "<leader>b", group = "Buffer" },
      { "<leader>u", group = "UI/Toggle" },
      { "<leader>q", group = "Session" },
    },
  },
}
