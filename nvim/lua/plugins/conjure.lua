return {
  -- TODO: Review if still usable
  "Olical/conjure",
  ft = { "clojure", "fennel" }, -- etc
  config = function()
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = vim.api.nvim_create_augroup("conjure_log_disable_lsp", { clear = true }),
      pattern = { "conjure-log-*" },
      callback = function()
        vim.diagnostic.enable(false)
      end,
      desc = "Conjure Log disable LSP diagnostics",
    })
    require("conjure.main").main()
    require("conjure.mapping")["on-filetype"]()
  end,
  init = function()
    -- Set configuration options here
    vim.g["conjure#debug"] = false
  end,
}
