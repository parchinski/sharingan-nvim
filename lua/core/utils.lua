local cmd = vim.cmd

local M = {}

local function is_module_available(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

function M.index_of(tbl, val, cmp)
  cmp = cmp or function(a, b)
    return a == b
  end
  for i, v in ipairs(tbl) do
    if cmp(v, val) then
      return i
    end
  end
  return -1
end

function M.reload(module)
  local has_plenary, plenary = pcall(require, 'plenary.reload')
  if has_plenary then
    plenary.reload_module(module)
  else
    package.loaded[module] = nil
  end
  require(module)
end

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Processes the layer definitions from the user config.
-- Layers can be defined in multiple ways:
-- 1. As a simple string: "layer_name"
--    This will be normalized to: { name = "layer_name", options = {} }
-- 2. As a table with name as first element: { "layer_name", opt1 = val1, opt2 = val2 }
--    This will be normalized to: { name = "layer_name", options = { opt1 = val1, opt2 = val2 } }
-- 3. As a table with explicit name and options: { name = "layer_name", options = { opt1 = val1 } }
--    This will be used as is.
-- 4. As a table with explicit name and inline options: { name = "layer_name", opt1 = val1 }
--    This will be normalized to: { name = "layer_name", options = { opt1 = val1 } }
local function get_layers(layers)
  local res = {}
  for _, layer in ipairs(layers) do
    if type(layer) == 'string' then
      layer = { name = layer, options = {} }
    elseif type(layer) == 'table' then
      -- Preserve the original table if it already has a name and options structure
      if not (layer.name and layer.options) then
        local name = table.remove(layer, 1) or layer.name
        if layer.options == nil then -- Handles cases 2 and 4
          layer = { name = name, options = layer }
        else -- Handles case where name was removed but options field existed
          layer = { name = name, options = layer.options }
        end
      end
    end
    res[#res + 1] = layer
  end
  return res
end

local _user_config

function M.get_user_config()
  if _user_config then
    return _user_config
  end
  local options = require('core.options')
  local ok, __user_config = pcall(dofile, options.user_config_path)

  if not ok then
    if string.find(tostring(__user_config), 'No such file or directory') then
      print('User config not found, creating from sample...')
      local sample_path = options.cosmos_configs_root .. '/.cosmos-nvim.sample.lua'
      local sample_config_file = io.open(sample_path, 'r')

      if sample_config_file then
        local sample_config_content = sample_config_file:read('*a')
        sample_config_file:close()

        local user_config_file = io.open(options.user_config_path, 'w')
        if user_config_file then
          user_config_file:write(sample_config_content)
          user_config_file:close()
          -- Attempt to load the newly created config
          local load_ok, loaded_config = pcall(dofile, options.user_config_path)
          if load_ok then
            __user_config = loaded_config
          else
            print(
              string.format(
                'Error loading newly created sample config at %s: %s',
                options.user_config_path,
                loaded_config
              )
            )
            __user_config = {} -- Fallback to an empty table
          end
        else
          print(string.format('Error: Could not open user config file for writing at %s', options.user_config_path))
          __user_config = {} -- Fallback to an empty table
        end
      else
        print(string.format('Error: Could not open sample config file at %s', sample_path))
        __user_config = {} -- Fallback to an empty table
      end
    else
      -- User config file exists but has errors, or another error occurred during dofile
      print('WARNING: User config file is invalid or unreadable:')
      print(tostring(__user_config)) -- Print the actual error message
      __user_config = {} -- Fallback to an empty table to prevent Neovim from crashing
    end
  end

  -- Ensure __user_config is a table before deepcopying
  if type(__user_config) ~= 'table' then
    print(
      string.format(
        'Warning: User config loaded into an unexpected type (%s), defaulting to empty table.',
        type(__user_config)
      )
    )
    __user_config = {}
  end

  _user_config = vim.deepcopy(__user_config)
  if _user_config.layers == nil then
    _user_config.layers = {
      'editor',
      'ui',
      'git',
      'completion',
    }
  end
  _user_config.layers = get_layers(_user_config.layers)
  if _user_config.options == nil then
    _user_config.options = {}
  end
  if _user_config.before_setup == nil then
    _user_config.before_setup = function() end
  end
  if _user_config.after_setup == nil then
    _user_config.after_setup = function() end
  end
  return _user_config
end

function M.reset_user_config()
  _user_config = nil
end

function M.fill_options(dest_options, new_options)
  for k, v in pairs(new_options) do
    local old_v = dest_options[k]
    if type(v) == 'table' and type(old_v) == 'table' then
      dest_options[k] = vim.tbl_deep_extend('force', old_v, v)
    else
      dest_options[k] = v
    end
  end
end

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

M.set_keymap = vim.api.nvim_set_keymap

local function _map(mode, shortcut, command)
  M.set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function M.map(shortcut, command)
  _map('', shortcut, command)
end

function M.nmap(shortcut, command)
  _map('n', shortcut, command)
end

function M.imap(shortcut, command)
  _map('i', shortcut, command)
end

function M.vmap(shortcut, command)
  _map('v', shortcut, command)
end

function M.cmap(shortcut, command)
  _map('c', shortcut, command)
end

function M.tmap(shortcut, command)
  _map('t', shortcut, command)
end

-- Highlights functions

-- Define bg color
-- @param group Group
-- @param color Color

M.bg = function(group, col)
  cmd('hi ' .. group .. ' guibg=' .. col)
end

-- Define fg color
-- @param group Group
-- @param color Color
M.fg = function(group, col)
  cmd('hi ' .. group .. ' guifg=' .. col)
end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
M.fg_bg = function(group, fgcol, bgcol)
  cmd('hi ' .. group .. ' guifg=' .. fgcol .. ' guibg=' .. bgcol)
end

return M
