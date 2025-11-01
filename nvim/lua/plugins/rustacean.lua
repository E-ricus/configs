return {
  {
    "mrcjkb/rustaceanvim",
    event = { "BufReadPre *.rs", "BufReadPre Cargo.toml" },
    config = function()
      -- Prompt for target selection before server starts (synchronous)
      local choice = vim.fn.confirm("Select Rust target:", "&Host\n&Windows", 1)

      -- Set target based on selection (1, cancelled = Host, 2 = Windows)
      if choice == 2 then
        vim.g.rust_analyzer_cargo_target = "x86_64-pc-windows-gnu"
      else
        -- Default to host (choice 1 or 0 for cancelled)
        vim.g.rust_analyzer_cargo_target = ""
      end
      --- @module 'rustaceanvim'
      --- @type rustaceanvim.Opts
      vim.g.rustaceanvim = {
        server = {
          settings = function(_)
            local base_settings = {
              ["rust-analyzer"] = {
                -- Disable for faster dev/ex
                checkOnSave = {
                  enable = false,
                },
                diagnostics = {
                  enable = false,
                },
                -- Disabling check and diagnostics in favor of compilemode for faster dev/ex
                -- check = {
                --   command = "clippy",
                --   workspace = false,
                -- },
                semanticHighlighting = {
                  -- So that SQL injections are highlighted
                  strings = {
                    enable = false,
                  },
                },
              },
            }

            -- Apply cargo target only if explicitly set
            if vim.g.rust_analyzer_cargo_target ~= "" then
              base_settings["rust-analyzer"].cargo = {
                target = vim.g.rust_analyzer_cargo_target,
              }
            end

            return base_settings
          end,
        },
      }

      -- Helper function to switch rust-analyzer target
      local function set_rust_target(target)
        vim.g.rust_analyzer_cargo_target = target
        vim.cmd.RustAnalyzer("restart")
        vim.notify("Rust target set to: " .. target, vim.log.levels.INFO)
      end

      -- Create user command for target switching
      vim.api.nvim_create_user_command("RustTarget", function(opts)
        set_rust_target(opts.args)
      end, {
        nargs = 1,
        desc = "Set rust-analyzer cargo target",
      })

      local map = function(keys, args, desc, mode)
        mode = mode or "n"
        local func = function()
          vim.cmd.RustLsp(args)
        end
        vim.keymap.set(mode, keys, func, { desc = "RustLSP: " .. desc })
      end

      -- keymaps
      local wk = require("which-key")
      wk.add({
        { "<leader>rt", group = "Rust Targets" },
        { "<leader>re", group = "Rust Expand/Explain" },
        { "<leader>rr", group = "Rust Render" },
        { "<leader>rc", group = "Rust Cargo/compile" },
      })

      vim.keymap.set("n", "<leader>rtw", function()
        set_rust_target("x86_64-pc-windows-gnu")
      end, { desc = "Set target to windows x86-gnu " })
      vim.keymap.set("n", "<leader>rth", function()
        set_rust_target("")
      end, { desc = "Set target back to host" })
      map("<leader>rd", "openDocs", "Open docs")
      map("<leader>rem", "expandMacro", "Expand Macro")
      map("<leader>ree", "explainError", "Explain Error")
      map("<leader>rrd", "renderDiagnostic", " Render Diagnostic")
      map("<leader>rco", "openCargo", "Open Cargo Toml")
    end,
    init = function()
      require("local.compilemode").setup({
        keymap = "<leader>cc",
        cargo = {
          enabled = true,
          default = "clippy",
          keymap = "<leader>rcc",
          on_save = false,
        },
        zig = {
          enabled = true,
          default = "check",
          keymap = nil,
          on_save = false,
        },
      })
    end,
  },
  {
    "saecki/crates.nvim",
    tag = "stable",
    lazy = true,
    event = { "BufReadPre Cargo.toml" },
    init = function()
      require("crates").setup({})
    end,
  },
}
