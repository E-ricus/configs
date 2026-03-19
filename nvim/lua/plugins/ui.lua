return {
  {
    "lucasadelino/jjtrack",
    event = "VeryLazy",
    config = function()
      require("jjtrack").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        extensions = { "fzf", "nvim-tree", "fugitive" },
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "|", right = "|" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          -- Show jj change ID with highlighted prefix when in a jj repo,
          -- otherwise fall back to the default git branch
          {
            function()
              local s = vim.b.jjtrack_summary
              if s and s.change_id_prefix then
                local parts = {}
                -- Change ID with highlighted prefix
                table.insert(parts, s.change_id_prefix .. (s.change_id_rest or ""))
                -- Bookmarks if any
                local bookmarks = s.local_bookmarks
                if bookmarks and #bookmarks > 0 then
                  local names = {}
                  for _, b in ipairs(bookmarks) do
                    table.insert(names, b)
                  end
                  table.insert(parts, "(" .. table.concat(names, ", ") .. ")")
                end
                -- Status indicators
                local status = {}
                if s.conflict then table.insert(status, "!") end
                if s.divergent then table.insert(status, "~") end
                if s.empty then table.insert(status, "o") end
                if #status > 0 then
                  table.insert(parts, "[" .. table.concat(status) .. "]")
                end
                return table.concat(parts, " ")
              end
              return ""
            end,
            cond = function()
              local s = vim.b.jjtrack_summary
              return s ~= nil and s.change_id_prefix ~= nil
            end,
            icon = "󱗆",
          },
          -- Fallback to git branch when not in a jj repo
          {
            "branch",
            cond = function()
              return vim.b.jjtrack_summary == nil or vim.b.jjtrack_summary.change_id_prefix == nil
            end,
          },
          "diff",
          "diagnostics",
        },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      cmdline = {
        view = "cmdline",
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
}
