return {
  {
    "mrcjkb/rustaceanvim",
    event = { "BufReadPre *.rs", "BufReadPre Cargo.toml" },
    config = function()
      -- Prompt for target selection before server starts (synchronous)
      local choice = vim.fn.confirm("Select Rust target:", "&Host\n&Windows\nWindows-&codebase", 1)

      -- Set target and features based on selection
      if choice == 2 then
        -- Windows only
        vim.g.rust_analyzer_cargo_target = "x86_64-pc-windows-gnu"
        vim.g.rust_analyzer_cargo_features = {}
      elseif choice == 3 then
        -- Windows with codebase features
        vim.g.rust_analyzer_cargo_target = "x86_64-pc-windows-gnu"
        vim.g.rust_analyzer_cargo_features = { "allow-window", "use-codebase-lib" }
      else
        -- Host (choice 1 or 0 for cancelled)
        vim.g.rust_analyzer_cargo_target = ""
        vim.g.rust_analyzer_cargo_features = {}
      end
      --- @module 'rustaceanvim'
      --- @type rustaceanvim.Opts
      vim.g.rustaceanvim = {
        server = {
          settings = function(_)
            local base_settings = {
              ["rust-analyzer"] = {
                -- Disable for faster dev/ex
                -- checkOnSave = {
                --   enable = false,
                -- },
                -- diagnostics = {
                --   enable = false,
                -- },
                -- disable check and diagnostics in favor of compilemode for faster dev/ex
                cargo = {},
                check = {
                  command = "clippy",
                  workspace = false,
                },
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
              base_settings["rust-analyzer"].cargo.target = vim.g.rust_analyzer_cargo_target
            end

            -- Apply cargo features if set
            if vim.g.rust_analyzer_cargo_features and #vim.g.rust_analyzer_cargo_features > 0 then
              base_settings["rust-analyzer"].cargo.features = vim.g.rust_analyzer_cargo_features
            end

            return base_settings
          end,
        },
      }

      -- Helper function to switch rust-analyzer target
      local function set_rust_target(target, features)
        vim.g.rust_analyzer_cargo_target = target
        vim.g.rust_analyzer_cargo_features = features or {}
        vim.cmd.RustAnalyzer("restart")
        local target_name = target ~= "" and target or "host"
        local features_str = features and #features > 0 and " with features: " .. table.concat(features, ", ") or ""
        vim.notify("Rust target set to: " .. target_name .. features_str, vim.log.levels.INFO)
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
      end, { desc = "Set target to windows x86-gnu" })
      vim.keymap.set("n", "<leader>rtwc", function()
        set_rust_target("x86_64-pc-windows-gnu", { "allow-window", "use-codebase-lib" })
      end, { desc = "Set target to windows x86-gnu with codebase features" })
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
