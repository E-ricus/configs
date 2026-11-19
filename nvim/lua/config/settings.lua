---- General settings ----
vim.opt.timeoutlen = 300
vim.opt.number = true
vim.opt.relativenumber = true
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
-- (indent-heuristic is a default since 0.12)
vim.opt.diffopt:append({ "algorithm:patience" })
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

-- Built-in message/cmdline UI redesign (0.12, experimental). Replaces noice.nvim.
-- No "Press ENTER" prompts, highlighted cmdline, messages pager. Remove if it misbehaves.
local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then
  ui2.enable()
end

-- Autocmds
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- Create a unique shada file per project directory to isolate jumplists
local shada_dir = vim.fn.stdpath("data") .. "/shada"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
vim.opt.shadafile = shada_dir .. "/main_" .. project_name .. ".shada"
