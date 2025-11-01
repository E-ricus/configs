-- TODO: Move it to sidekick.nvim when added.
return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  enabled = false,
  config = function()
    local copilot = require("copilot")
    copilot.setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
      },
    })
    local map = vim.keymap.set
    map("i", "<C-a>", require("copilot.suggestion").accept_line, { noremap = true, desc = "Accept copilot suggestion" })
    map("i", "<C-n>", require("copilot.suggestion").next, { noremap = true, desc = "Next copilot suggestion" })
    map("i", "<C-p>", require("copilot.suggestion").prev, { noremap = true, desc = "Prev copilot suggestion" })
  end,
}
