return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  opts = {
    -- add any custom options here
  },
  keys = {
    {
      "<leader>qs",
      function()
        require("persistence").load()
      end,
      desc = "Load the session current directory",
    },
    {
      "<leader>qS",
      function()
        require("persistence").select()
      end,
      desc = "Select session to load",
    },
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Load last session",
    },
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save session on exit",
    },
  },
}
