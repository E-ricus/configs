-- TODO: Nvim 0.12 supports this natively (no plugin needed): install copilot-language-server, then
--   vim.lsp.enable("copilot") and vim.lsp.inline_completion.enable()
-- (see :h lsp-inline_completion). sidekick.nvim builds on top of that if you want NES/AI CLI integration.
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
