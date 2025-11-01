local map = vim.keymap.set

-- WTF NVIM
--I don't want these defaults?
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grt")

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

map({ "n", "v" }, "H", "^")
map({ "n", "v" }, "L", "$")

map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Word wrap" })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Word wrap" })

map({ "n", "v" }, "<C-h>", "<cmd>noh<CR>", { noremap = true, desc = "Clear search" })

map({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, desc = "Delete without yank" })

map({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, desc = "Copy to clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { noremap = true, desc = "Paste from clipboard" })

map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, desc = "Move line up" })

map("n", "J", "mzJ`z", { noremap = true, desc = "Move next line up" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Page up" })
map("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Page down" })
-- Next centered
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("i", "<C-c>", "<Esc>")

map("n", "<leader><tab>", "<C-^>", { noremap = true, desc = "Last buffer" })
map("n", "<leader><left>", "<cmd>bp<CR>", { noremap = true, desc = "Previous buffer" })
map("n", "<leader><right>", "<cmd>bn<CR>", { noremap = true, desc = "Next buffer" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { silent = true, desc = "Exit term mode" })
