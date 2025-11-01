---- General settings ----
vim.opt.timeoutlen = 300
vim.opt.number = true
vim.opt.relativenumber = true
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.opt.diffopt:append({ "algorithm:patience", "indent-heuristic" })
vim.opt.smartcase = true
vim.opt.scrolloff = 5
vim.opt.mouse = "a"
vim.opt.shortmess:append("c")
vim.opt.completeopt = { "menuone", "noinsert", "noselect" } --Better completion
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- vim.opt.colorcolumn = 80
-- Proper search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true
-- Sane splits
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Better display for messages
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.showmode = false
vim.cmd("syntax on")

-- Autocmds
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
