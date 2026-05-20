return {
  {
    dir = vim.fn.stdpath("config") .. "/local-plugins/compilemode",
    name = "compilemode",
    ft = { "rust", "zig", "c3" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("compilemode").setup({
        keymap = "<leader>cc",
        languages = {
          rust = {
            mode = "cargo",
            default = "clippy",
            keymap = "<leader>rcc",
            on_save = false,
          },
          zig = {
            mode = "zig",
            default = "check",
            keymap = nil,
            on_save = false,
          },
          c3 = {
            mode = "c3",
            default = "build",
            keymap = "<leader>c3c",
            on_save = false,
          },
        },
      })
    end,
  },
}
