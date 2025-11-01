local function hide_diagnostics()
  vim.diagnostic.config({ -- https://neovim.io/doc/user/diagnostic.html
    virtual_text = false,
    signs = false,
    underline = false,
  })
end
local function show_diagnostics()
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
  })
end

local servers = {
  -- rust-analyzer is handled by rustacean.nvim in rustacean.lua
  pylsp = {},
  c3_lsp = {},
  mojo = {},
  clojure_lsp = {},
  sourcekit = {},
  zls = {},
  ols = {},
  gleam = {},
  lua_ls = {},
  elixirls = {},
  hls = { filetypes = { "haskell", "lhaskell", "cabal" } },
  vtsls = {},
  denols = {},
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        codelenses = {
          gc_details = true, --  // Show a code lens toggling the display of gc's choices.
          test = true,
        },
      },
    },
  },
}

return {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = {
    {
      "williamboman/mason.nvim",
      init = function()
        require("mason").setup()
      end,
    },
    "onsails/lspkind-nvim",
  },
  config = function()
    for server, config in pairs(servers) do
      if server == "denols" then
        config.root_markers = { "deno.json", "deno.jsonc" }
        config.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
      end
      if server == "vtsls" then
        config.root_markers = { "package.json" }
        config.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
      end
      -- Set up the LSP config
      vim.lsp.config[server] = config
      -- Enable the server
      vim.lsp.enable(server)
    end
    -- Diagnostics
    vim.diagnostic.config({ virtual_text = true })
  end,
  keys = {
    -- Moved to snacks
    -- { "gd", vim.lsp.buf.definition, desc = "LSP go to definition" },
    -- { "gD", vim.lsp.buf.declaration, desc = "LSP go to declaration" },
    -- { "gi", vim.lsp.buf.implementation, desc = "LSP go to implementation" },
    { "<leader>k", vim.lsp.buf.hover, desc = "LSP Hover" },
    { "<leader>cr", vim.lsp.buf.rename, desc = "LSP rename" },
    {
      "[d",
      function()
        vim.diagnostic.jump({ count = -1 })
        vim.diagnostic.open_float()
      end,
      desc = "LSP go to previous diagnostic",
    },
    {
      "]d",
      function()
        vim.diagnostic.jump({ count = 1 })
        vim.diagnostic.open_float()
      end,
      desc = "LSP go to next diagnostic",
    },
    { "<leader>df", vim.diagnostic.open_float, desc = "LSP diagnostic float" },
    { "<leader>dh", hide_diagnostics, desc = "LSP hide diagnostics" },
    { "<leader>ds", show_diagnostics, desc = "LSP show diagnostics" },
    { "<C-k>", vim.lsp.buf.signature_help, mode = { "n", "i" }, desc = "LSP signature help" },
    { "<leader>ca", vim.lsp.buf.code_action, desc = "LSP code actions" },
    { "<leader>lR", vim.lsp.codelens.run, desc = "LSP run lens" },
    { "<leader>ll", vim.lsp.codelens.refresh, desc = "LSP refresh lens" },
  },
}
