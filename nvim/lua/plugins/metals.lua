-- TODO: Review if still usable
local M = {
  "scalameta/nvim-metals",
  event = { "BufReadPre *.scala", "BufReadPre *.sbt" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

function M.config()
  local metals_config = require("metals").bare_config()
  -- Example of settings
  metals_config.settings = {
    showImplicitArguments = true,
    excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
  }
  -- Autocmd that will actually be in charging of starting the whole thing
  local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = function()
      require("metals").initialize_or_attach(metals_config)
    end,
    group = nvim_metals_group,
  })
end

--
return M
