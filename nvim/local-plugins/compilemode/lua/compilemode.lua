local M = {}
local private = {}

---@class LanguageConfig
---@field mode string Key into the LANGS registry (e.g. "cargo", "zig", "c3")
---@field default string Default subcommand for this language (e.g. "clippy", "build")
---@field keymap string|nil Buffer-local keymap that runs the default command
---@field on_save boolean Whether to re-run the last command on buffer save

---@class CompileModeConfig
---@field keymap string|nil Global keymap to recompile the last command
---@field languages table<string, LanguageConfig> Map of filetype -> language config

---@type CompileModeConfig
local default_config = {
  keymap = "<leader>cc",
  languages = {},
}

---@type CompileModeConfig
local config = vim.deepcopy(default_config)

-- Last :Compile invocation, for recompile (<leader>cc).
---@type {mode: string, args: string[]}|nil
local last_command = nil

-- Per-buffer active language state, populated by the FileType autocmd.
---@type table<integer, {mode: string, default: string}>
local lang_state = {}

---@class QuickfixItem
---@field filename string
---@field lnum integer
---@field col integer
---@field text string
---@field type string "E" | "W" | "I" | "H"

---Cargo (rust) JSON formatter, parses --message-format=json output.
---@param data string[]
---@param items QuickfixItem[]
local function cargo_formatter(data, items)
  local function process_span(msg, span, is_child)
    local qf_type = "I"
    local label = ""
    if msg.level == "error" then
      qf_type = "E"
      label = span.label or ""
    elseif msg.level == "warning" then
      qf_type = "W"
    elseif msg.level == "note" or msg.level == "help" then
      qf_type = "H"
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

  for _, line in ipairs(data) do
    if line and line ~= "" then
      local ok, decoded = pcall(vim.json.decode, line)
      if ok and decoded.message then
        local msg = decoded.message
        if msg.spans and #msg.spans > 0 then
          table.insert(items, process_span(msg, msg.spans[1], false))
          if msg.children then
            for _, child in ipairs(msg.children) do
              if child.spans and #child.spans > 0 then
                table.insert(items, process_span(child, child.spans[1], true))
              end
            end
          end
        end
      end
    end
  end
end

---Zig text formatter for `zig build` / `zig run` output.
---@param data string[]
---@param items QuickfixItem[]
local function zig_formatter(data, items)
  local pattern = "([^:]+):(%d+):(%d+):%s+(%w+):%s+(.+)"
  local current_item = nil
  for _, line in ipairs(data) do
    local filename, lnum, col, type, text = line:match(pattern)
    if filename then
      current_item = {
        filename = filename,
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = type:sub(1, 1):upper(),
        text = text,
      }
      table.insert(items, current_item)
    elseif current_item and line:match("^%s+") then
      current_item.text = current_item.text .. "\n" .. line:gsub("^%s+", "")
    end
  end
end

---C3 (c3c) text formatter. c3c writes diagnostics like:
---   (path/file.c3:LINE:COL) Error: message
---   (path/file.c3:LINE:COL) Warning: message
---   (path/file.c3:LINE:COL) Note: message
---Notes are folded into the preceding Error/Warning rather than emitted
---as standalone entries. The "Inlined from here." note is the common
---c3c idiom for macro errors that originate in the stdlib: when seen,
---the preceding entry's location is relocated to the note's call site
---(your code) and the original origin is appended to the text. Other
---notes are appended to the preceding entry's text with their location.
---@param data string[]
---@param items QuickfixItem[]
local function c3_formatter(data, items)
  local pattern = "^%s*%((.-):(%d+):(%d+)%)%s+(%w+):%s+(.*)$"
  local last = nil

  for _, line in ipairs(data) do
    if line and line ~= "" then
      local fname, lnum_s, col_s, severity, text = line:match(pattern)
      if fname then
        local lnum, col = tonumber(lnum_s), tonumber(col_s)
        if severity == "Note" and last then
          if text == "Inlined from here." then
            -- Relocate the preceding entry to this call site and
            -- preserve the original location in the text.
            last.text = last.text .. string.format("  (origin: %s:%d:%d)", last.filename, last.lnum, last.col)
            last.filename = fname
            last.lnum = lnum
            last.col = col
          else
            -- Append other notes as continuation text on the preceding entry.
            last.text = last.text .. string.format("\n  ↳ Note: %s (at %s:%d:%d)", text, fname, lnum, col)
          end
        else
          local qf_type = "I"
          if severity == "Error" then
            qf_type = "E"
          elseif severity == "Warning" then
            qf_type = "W"
          end
          local entry = {
            filename = fname,
            lnum = lnum,
            col = col,
            type = qf_type,
            text = severity .. ": " .. text,
          }
          table.insert(items, entry)
          last = entry
        end
      end
    end
  end
end

---@class LangDef
---@field name string Display name
---@field cmd string Executable
---@field subcommands string[] Subcommand completions for :Compile
---@field extra_args string[] Args appended after the user-supplied args
---@field formatter fun(data: string[], items: QuickfixItem[])

---@type table<string, LangDef>
local LANGS = {
  cargo = {
    name = "cargo",
    cmd = "cargo",
    subcommands = { "clippy", "check", "build", "test", "run", "bench", "doc" },
    extra_args = { "--message-format=json" },
    formatter = cargo_formatter,
  },
  zig = {
    name = "zig",
    cmd = "zig",
    subcommands = { "build", "run", "test" },
    extra_args = {},
    formatter = zig_formatter,
  },
  c3 = {
    name = "c3",
    cmd = "c3c",
    subcommands = { "build", "run", "test", "clean", "benchmark", "compile", "compile-run" },
    extra_args = {},
    formatter = c3_formatter,
  },
}

---Generic async compile runner.
---@param command string[]
---@param formatter fun(data: string[], items: QuickfixItem[])
---@param success_message string
---@param error_message string
function private.run(command, formatter, success_message, error_message)
  local Job = require("plenary.job")
  local items = {}
  local output_lines = {}

  vim.notify("Compiling command: " .. table.concat(command, " "), vim.log.levels.INFO)
  Job:new({
    command = command[1],
    args = vim.list_slice(command, 2),
    on_stdout = function(_, line)
      table.insert(output_lines, line)
    end,
    on_stderr = function(_, line)
      table.insert(output_lines, line)
    end,
    on_exit = function(_, exit_code)
      formatter(output_lines, items)
      vim.schedule(function()
        if exit_code == 0 then
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

---Run a language with the given args (args[1] is the subcommand).
---@param mode string Key into LANGS
---@param args string[]|nil
function private.compile_lang(mode, args)
  local lang = LANGS[mode]
  if not lang then
    vim.notify("compilemode: unknown mode '" .. mode .. "'", vim.log.levels.ERROR)
    return
  end

  -- Fall back to per-buffer default, otherwise the language's first subcommand.
  if not args or #args == 0 then
    local buf_state = lang_state[vim.api.nvim_get_current_buf()]
    local default = (buf_state and buf_state.mode == mode and buf_state.default) or lang.subcommands[1]
    args = { default }
  end

  local cmd = { lang.cmd }
  vim.list_extend(cmd, args)
  vim.list_extend(cmd, lang.extra_args)

  local label = lang.name .. " " .. table.concat(args, " ")
  private.run(cmd, lang.formatter, label .. " complete - no issues", label .. " complete - found issues")
end

---Activate a language for a given buffer based on its filetype.
---@param buf integer
---@param ft string
function private.on_filetype(buf, ft)
  local entry = config.languages[ft]
  if not entry then
    return
  end
  if not LANGS[entry.mode] then
    vim.notify(
      "compilemode: filetype '" .. ft .. "' references unknown mode '" .. entry.mode .. "'",
      vim.log.levels.WARN
    )
    return
  end

  lang_state[buf] = { mode = entry.mode, default = entry.default }

  if entry.keymap then
    vim.keymap.set("n", entry.keymap, function()
      private.compile_lang(entry.mode, { entry.default })
    end, { buffer = buf, desc = "compilemode: " .. entry.mode .. " " .. entry.default })
  end

  if entry.on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = buf,
      callback = function()
        local args = last_command and last_command.args or { entry.default }
        private.compile_lang(entry.mode, args)
      end,
      desc = "compilemode: run " .. entry.mode .. " on save",
    })
  end
end

---Completion for :Compile
---@param arg_lead string
---@param cmd_line string
---@param _cursor_pos integer
---@return string[]
function private.compile_completion(arg_lead, cmd_line, _cursor_pos)
  local args = vim.split(cmd_line, "%s+", { trimempty = true })
  local completing_position = #args
  if arg_lead == "" then
    completing_position = #args + 1
  end

  if completing_position == 2 then
    -- Only offer modes that are referenced in the user's language config.
    local available = {}
    for _, entry in pairs(config.languages) do
      if not vim.tbl_contains(available, entry.mode) then
        table.insert(available, entry.mode)
      end
    end
    return vim.tbl_filter(function(mode)
      return vim.startswith(mode, arg_lead)
    end, available)
  end

  if completing_position == 3 then
    local lang = LANGS[args[2]]
    if lang then
      return vim.tbl_filter(function(sub)
        return vim.startswith(sub, arg_lead)
      end, lang.subcommands)
    end
  end

  return {}
end

function private.create_compile_command()
  vim.api.nvim_create_user_command("Compile", function(opts)
    local args = opts.fargs

    if #args == 0 then
      -- Prefer the last command if there was one.
      if last_command then
        private.compile_lang(last_command.mode, last_command.args)
        return
      end
      -- Otherwise dispatch based on the current buffer's active language.
      local buf_state = lang_state[vim.api.nvim_get_current_buf()]
      if buf_state then
        last_command = { mode = buf_state.mode, args = { buf_state.default } }
        private.compile_lang(buf_state.mode, { buf_state.default })
        return
      end
      -- Nothing to do; report available modes.
      local available = {}
      for _, entry in pairs(config.languages) do
        if not vim.tbl_contains(available, entry.mode) then
          table.insert(available, entry.mode)
        end
      end
      if #available == 0 then
        vim.notify("No compile modes configured", vim.log.levels.WARN)
      else
        vim.notify("Available compile modes: " .. table.concat(available, ", "), vim.log.levels.INFO)
      end
      return
    end

    local mode = args[1]
    local mode_args = vim.list_slice(args, 2)
    if not LANGS[mode] then
      vim.notify("Unknown compile mode: " .. mode, vim.log.levels.ERROR)
      return
    end
    last_command = { mode = mode, args = mode_args }
    private.compile_lang(mode, mode_args)
  end, {
    nargs = "*",
    desc = "Run compile command",
    complete = private.compile_completion,
  })
end

function private.setup_global_keymap()
  if config.keymap then
    vim.keymap.set("n", config.keymap, function()
      vim.cmd("Compile")
    end, { desc = "compilemode: run last compile command" })
  end
end

---@param user_config CompileModeConfig|nil
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config or {})

  private.create_compile_command()
  private.setup_global_keymap()

  local filetypes = vim.tbl_keys(config.languages)
  if #filetypes > 0 then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function(args)
        private.on_filetype(args.buf, args.match)
      end,
      desc = "compilemode: activate language for filetype",
    })

    -- Lazy may load this plugin via `ft = {...}`, in which case the
    -- FileType event for the triggering buffer has already fired by the
    -- time setup() runs. Activate the current buffer manually if needed.
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_ft = vim.bo[cur_buf].filetype
    if config.languages[cur_ft] then
      private.on_filetype(cur_buf, cur_ft)
    end
  end
end

return M
