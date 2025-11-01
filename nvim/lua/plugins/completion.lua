return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "VimEnter",
  dependencies = {
    -- Snippet Engine
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      opts = {},
    },
    "folke/lazydev.nvim",
    { "xzbdmw/colorful-menu.nvim", opts = {} },
    "moyiz/blink-emoji.nvim",
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",

      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<Enter>"] = { "select_and_accept", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },

      ["<C-d>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
      list = {
        selection = {
          preselect = false,
        },
      },
      menu = {
        draw = {
          -- We don't need label_description now because label and label_description are already
          -- combined together in label by colorful-menu.nvim.
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
    },

    sources = {
      default = {
        "lsp",
        "path",
        "lazydev",
        "emoji",
        "buffer",
      },
      providers = {
        lsp = {
          async = true,
        },
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
          opts = {
            insert = true, -- Insert emoji (default) or complete its name
            ---@type string|table|fun():table
            trigger = function()
              return { ":" }
            end,
          },
        },
      },
    },

    snippets = { preset = "luasnip" },

    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  },
}
