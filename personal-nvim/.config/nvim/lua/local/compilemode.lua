local M = {}
local private = {}
local cargo = {}
local zig = {}

---@class CargoConfig
---@field enabled boolean Whether cargo compilation is enabled
---@field default string Default cargo subcommand (e.g., "clippy", "check", "build", "test")
---@field keymap string|nil Keymap to trigger the default cargo command
---@field on_save boolean Whether to run cargo command on file save
---
---@class ZigConfig
---@field enabled boolean Whether zig build compilation is enabled
---@field default string Default zig build subcommand (e.g., "check", "run", "test")
---@field keymap string|nil Keymap to trigger the default zig build command
---@field on_save boolean Whether to run zig build command on file save

---@class CompileModeConfig
---@field cargo CargoConfig Cargo-specific configuration
---@field zig ZigConfig Zig-specific configuration
---@field keymap string|nil Keymap to trigger recompilation of last command

---@type CompileModeConfig
local default_config = {
  keymap = "<leader>cc",
  cargo = {
    enabled = false,
    default = "clippy",
    keymap = nil,
    on_save = false,
  },
  zig = {
    enabled = false,
    default = "check",
    keymap = nil,
    on_save = false,
  },
}

---@type CompileModeConfig
local config = vim.deepcopy(default_config)

-- Store the last compile command for recompilation
---@type {mode: string, args: string[]}|nil
local last_command = nil

---@class QuickfixItem
---@field filename string Path to the file
---@field lnum integer Line number
---@field col integer Column number
---@field text string Error/warning message text
---@field type string Quickfix type: "E" (error), "W" (warning), "H" (hint), "I" (info)

---Helper function to process a single span into a quickfix item
---@param msg table Message object containing level and message text
---@param span table Span object with file location information
---@param is_child boolean Whether this is a child message
---@return QuickfixItem Formatted quickfix item
local function process_cargo_span(msg, span, is_child)
  local qf_type = "I" -- Default to info
  local label = ""

  if msg.level == "error" then
    qf_type = "E"
    label = span.label or ""
  elseif msg.level == "warning" then
    qf_type = "W"
  elseif msg.level == "note" or msg.level == "help" then
    qf_type = "H" -- Hint/Help
    label = span.suggested_replacement or ""
  end

  local prefix = is_child and "  → " or ""
  local text = prefix .. msg.message .. (label ~= "" and "\n" .. label or "")

  return {
    filename = span.file_name,
    lnum = span.line_start,
    col = span.column_start,
    text = text,
    type = qf_type,
  }
end

---Parses cargo JSON output into quickfix items
---@param data string[] Array of JSON output lines from cargo
---@param items QuickfixItem[] Table to populate with parsed quickfix items
function cargo.formatter(data, items)
  for _, line in ipairs(data) do
    if line and line ~= "" then
      local ok, decoded = pcall(vim.json.decode, line)
      if ok and decoded.message then
        local msg = decoded.message
        if msg.spans and #msg.spans > 0 then
          -- Process main span
          table.insert(items, process_cargo_span(msg, msg.spans[1], false))

          -- Process child spans
          if msg.children then
            for _, child in ipairs(msg.children) do
              if child.spans and #child.spans > 0 then
                table.insert(items, process_cargo_span(child, child.spans[1], true))
              end
            end
          end
        end
      end
    end
  end
end

---Constructs the full cargo command with JSON message format
---@param args string[]|nil Array of cargo arguments (defaults to {config.cargo.default})
---@return string[] Command array suitable for job execution
function cargo.build_command(args)
  args = args or { config.cargo.default }
  local cmd = { "cargo" }
  vim.list_extend(cmd, args)
  table.insert(cmd, "--message-format=json")
  return cmd
end

---Generates success message for cargo command
---@param args string[]|nil Array of cargo arguments (defaults to {config.cargo.default})
---@return string Success notification message
function cargo.success_message(args)
  args = args or { config.cargo.default }
  return "cargo " .. args[1] .. " complete - no issues"
end

---Generates error message for cargo command
---@param args string[]|nil Array of cargo arguments (defaults to {config.cargo.default})
---@return string Error notification message
function cargo.error_message(args)
  args = args or { config.cargo.default }
  return "cargo " .. args[1] .. " complete - found issues"
end

---Executes cargo compile command with specified arguments
---@param args string[]|nil Array of arguments starting with the subcommand
function cargo.compile(args)
  local cmd = cargo.build_command(args)
  local success_msg = cargo.success_message(args)
  local error_msg = cargo.error_message(args)

  private.compile(cmd, cargo.formatter, success_msg, error_msg)
end

---Sets up autocmd to run cargo command on file save
function cargo.setup_autocmd()
  if config.cargo.on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.rs", "Cargo.toml" },
      callback = function()
        if last_command then
          cargo.compile(last_command.args)
        else
          cargo.compile()
        end
      end,
      desc = "Run cargo compile on save",
    })
  end
end

---Sets up keymap for cargo default command
function cargo.setup_keymap()
  if config.cargo.keymap then
    vim.keymap.set("n", config.cargo.keymap, function()
      cargo.compile()
    end, { desc = "Run cargo default command:" .. config.cargo.default })
  end
end

---Initializes cargo module with autocmd and keymap
function cargo.setup()
  if config.cargo.enabled then
    cargo.setup_autocmd()
    cargo.setup_keymap()
  end
end

---Parses zig build output into quickfix items
---@param data string[] output lines from zig build
---@param items QuickfixItem[] Table to populate with parsed quickfix items
function zig.formatter(data, items)
  local pattern = "([^:]+):(%d+):(%d+):%s+(%w+):%s+(.+)"
  local current_item = nil

  for _, line in ipairs(data) do
    local filename, lnum, col, type, text = line:match(pattern)

    if filename then
      -- New error/warning/note
      current_item = {
        filename = filename,
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = type:sub(1, 1):upper(),
        text = text,
      }
      table.insert(items, current_item)
      -- TODO: Double check this beahavior
    elseif current_item and line:match("^%s+") then
      -- Continuation line (indented)
      current_item.text = current_item.text .. "\n" .. line:gsub("^%s+", "")
    end
  end
end

---Constructs the full zig command
---@param args string[]|nil Array of zig arguments (defaults to {config.zig.default})
---@return string[] Command array suitable for job execution
function zig.build_command(args)
  args = args or { config.zig.default }
  local cmd = { "zig" }
  vim.list_extend(cmd, args)
  return cmd
end

---Generates success message for zig build command
---@param args string[]|nil Array of zig arguments (defaults to {config.zig.default})
---@return string Success notification message
function zig.success_message(args)
  args = args or { config.zig.default }
  return "zig " .. table.concat(args, " ") .. " complete - no issues"
end

---Generates error message for zig build command
---@param args string[]|nil Array of zig arguments (defaults to {config.zig.default})
---@return string Error notification message
function zig.error_message(args)
  args = args or { config.zig.default }
  return "zig " .. table.concat(args, " ") .. " complete - found issues"
end

---Executes zig compile command with specified arguments
---@param args string[]|nil Array of arguments starting with the subcommand
function zig.compile(args)
  local cmd = zig.build_command(args)
  local success_msg = zig.success_message(args)
  local error_msg = zig.error_message(args)

  private.compile(cmd, zig.formatter, success_msg, error_msg)
end

---Sets up autocmd to run zig command on file save
function zig.setup_autocmd()
  if config.zig.on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.zig", "*.zig.zon" },
      callback = function()
        if last_command then
          zig.compile(last_command.args)
        else
          zig.compile()
        end
      end,
      desc = "Run zig build compile on save",
    })
  end
end

---Sets up keymap for zig default command
function zig.setup_keymap()
  if config.zig.keymap then
    vim.keymap.set("n", config.zig.keymap, function()
      zig.compile()
    end, { desc = "Run zig " .. config.zig.default })
  end
end

---Initializes cargo module with autocmd and keymap
function zig.setup()
  if config.zig.enabled then
    zig.setup_autocmd()
    zig.setup_keymap()
  end
end

---Generic compile function using plenary.job for async execution
---@param command string[] Command array where first element is the executable
---@param formatter fun(data: string[], items: QuickfixItem[]) Function to parse command output into quickfix items
---@param success_message string Message to display on successful completion
---@param error_message string Message to display on error completion
function private.compile(command, formatter, success_message, error_message)
  local Job = require("plenary.job")
  local items = {}
  local stdout_lines = {}

  vim.notify("Compiling command: " .. table.concat(command, " "), vim.log.levels.INFO)
  Job:new({
    command = command[1],
    args = vim.list_slice(command, 2),
    on_stdout = function(_, line)
      table.insert(stdout_lines, line)
    end,
    on_stderr = function(_, data)
      table.insert(stdout_lines, data)
    end,
    on_exit = function(_, exit_code)
      -- Process all stdout lines with the formatter
      formatter(stdout_lines, items)

      vim.schedule(function()
        if exit_code == 0 then
          -- TODO: Maybe check if in some circustances it should also close in success
          vim.notify(success_message, vim.log.levels.INFO)
        else
          vim.notify(error_message, vim.log.levels.WARN)
          if #items > 0 then
            vim.cmd("copen")
          end
        end
        vim.fn.setqflist(items)
      end)
    end,
  }):start()
end

---Returns list of available compile modes
---@return string[] List of enabled compile modes
function private.get_available_modes()
  local available = {}
  if config.cargo.enabled then
    table.insert(available, "cargo")
  end
  if config.zig.enabled then
    table.insert(available, "zig")
  end
  return available
end

---Command completion function for :Compile
---@param arg_lead string Current argument being typed
---@param cmd_line string Full command line
---@param cursor_pos integer Cursor position in command line
---@return string[] List of completion candidates
function private.compile_completion(arg_lead, cmd_line, cursor_pos)
  local args = vim.split(cmd_line, "%s+", { trimempty = true })

  -- args[1] is "Compile", args[2] is mode, args[3] is subcommand, then it should be args
  local completing_position = #args
  if arg_lead == "" then
    completing_position = #args + 1
  end

  -- mode (command)
  if completing_position == 2 then
    local available = private.get_available_modes()
    return vim.tbl_filter(function(mode)
      return vim.startswith(mode, arg_lead)
    end, available)
  end

  -- sub command
  if completing_position == 3 then
    local mode = args[2]

    if mode == "cargo" and config.cargo.enabled then
      local cargo_subcommands = { "clippy", "check", "build", "test", "run", "bench", "doc" }
      return vim.tbl_filter(function(subcmd)
        return vim.startswith(subcmd, arg_lead)
      end, cargo_subcommands)
    elseif mode == "zig" and config.zig.enabled then
      local zig_subcommands = { "build", "run", "test" }
      return vim.tbl_filter(function(subcmd)
        return vim.startswith(subcmd, arg_lead)
      end, zig_subcommands)
    end
  end

  return {}
end

---Creates the :Compile user command with subcommand support
function private.create_compile_command()
  vim.api.nvim_create_user_command("Compile", function(opts)
    local args = opts.fargs

    if #args == 0 then
      -- If there's a last command, recompile it
      if last_command then
        if last_command.mode == "cargo" and config.cargo.enabled then
          cargo.compile(last_command.args)
        end
        if last_command.mode == "zig" and config.zig.enabled then
          zig.compile(last_command.args)
        end
        return
      end

      -- Otherwise, show available compile modes
      local available = private.get_available_modes()

      if #available == 0 then
        vim.notify("No compile modes enabled", vim.log.levels.WARN)
      else
        vim.notify("Available compile modes: " .. table.concat(available, ", "), vim.log.levels.INFO)
      end
      return
    end

    local mode = args[1]
    local mode_args = vim.list_slice(args, 2)

    if mode == "cargo" and config.cargo.enabled then
      -- Store this command as the last command
      last_command = { mode = mode, args = mode_args }
      cargo.compile(mode_args)
    elseif mode == "zig" and config.zig.enabled then
      -- Store this command as the last command
      last_command = { mode = mode, args = mode_args }
      zig.compile(mode_args)
    else
      vim.notify("Unknown or disabled compile mode: " .. mode, vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    desc = "Run compile command",
    complete = private.compile_completion,
  })
end

---Sets up the global keymap for recompilation
function private.setup_global_keymap()
  if config.keymap then
    vim.keymap.set("n", config.keymap, function()
      vim.cmd("Compile")
    end, { desc = "Run last compile command" })
  end
end

---Main setup function to initialize the compile mode plugin
---@param user_config CompileModeConfig|nil User configuration to override defaults
function M.setup(user_config)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend("force", default_config, user_config or {})

  private.create_compile_command()

  private.setup_global_keymap()

  -- TODO: This are identical, just changing file type and command table, probably refactor to make more generic
  cargo.setup()
  zig.setup()
end

return M
