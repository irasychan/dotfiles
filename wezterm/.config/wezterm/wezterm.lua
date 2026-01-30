-- WezTerm Configuration
-- Tokyo Night theme - aligned with Windows Terminal and Starship configs

local wezterm = require 'wezterm'
local config = {}

-- Use config builder for better error messages in newer WezTerm versions
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ============================================================================
-- Color Scheme - Tokyo Night
-- ============================================================================

config.color_scheme = 'Tokyo Night'

-- Custom Tokyo Night colors (matching your Windows Terminal config)
config.colors = {
  foreground = '#C0CAF5',
  background = '#1A1B26',
  cursor_bg = '#C0CAF5',
  cursor_fg = '#1A1B26',
  cursor_border = '#C0CAF5',
  selection_fg = '#C0CAF5',
  selection_bg = '#414868',

  scrollbar_thumb = '#565F89',

  split = '#565F89',

  -- ANSI colors
  ansi = {
    '#414868', -- black
    '#F7768E', -- red
    '#9ECE6A', -- green
    '#E0AF68', -- yellow
    '#7AA2F7', -- blue
    '#BB9AF7', -- magenta/purple
    '#7DCFFF', -- cyan
    '#C0CAF5', -- white
  },

  brights = {
    '#565F89', -- bright black
    '#F7768E', -- bright red
    '#9ECE6A', -- bright green
    '#E0AF68', -- bright yellow
    '#7AA2F7', -- bright blue
    '#BB9AF7', -- bright magenta/purple
    '#7DCFFF', -- bright cyan
    '#C0CAF5', -- bright white
  },

  -- Tab bar colors
  tab_bar = {
    background = '#16161E',
    active_tab = {
      bg_color = '#1A1B26',
      fg_color = '#C0CAF5',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = '#16161E',
      fg_color = '#565F89',
    },
    inactive_tab_hover = {
      bg_color = '#292E42',
      fg_color = '#C0CAF5',
      italic = true,
    },
    new_tab = {
      bg_color = '#16161E',
      fg_color = '#565F89',
    },
    new_tab_hover = {
      bg_color = '#292E42',
      fg_color = '#C0CAF5',
      italic = true,
    },
  },
}

-- ============================================================================
-- Font Configuration
-- ============================================================================

config.font = wezterm.font_with_fallback {
  'CaskaydiaCove Nerd Font',
  'Cascadia Code',
  'JetBrains Mono',
}

config.font_size = 10.0
config.line_height = 1.0
config.cell_width = 1.0

-- Enable font features for ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- ============================================================================
-- Window Configuration
-- ============================================================================

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.initial_cols = 120
config.initial_rows = 30

config.window_background_opacity = 1.0
config.text_background_opacity = 1.0

-- Window decorations
config.window_decorations = "RESIZE"

-- Enable scrollbar
config.enable_scroll_bar = true

-- ============================================================================
-- Tab Bar Configuration
-- ============================================================================

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 25

-- Tab bar style
config.window_frame = {
  font = wezterm.font { family = 'CaskaydiaCove Nerd Font', weight = 'Regular' },
  font_size = 10.0,
  active_titlebar_bg = '#16161E',
  inactive_titlebar_bg = '#16161E',
}

-- ============================================================================
-- Cursor Configuration
-- ============================================================================

config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0
config.cursor_thickness = '1px'

-- ============================================================================
-- Scrollback
-- ============================================================================

config.scrollback_lines = 10000

-- ============================================================================
-- Bell
-- ============================================================================

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- ============================================================================
-- Performance
-- ============================================================================

config.max_fps = 144
config.animation_fps = 60
config.front_end = "WebGpu"

-- ============================================================================
-- Behavior
-- ============================================================================

config.automatically_reload_config = true
config.check_for_updates = true
config.show_update_window = true

-- Exit behavior
config.exit_behavior = 'CloseOnCleanExit'
config.skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
  'pwsh',
  'powershell',
}

-- Selection behavior
config.selection_word_boundary = " \t\n{}[]()\"'`"


-- ============================================================================
-- Key Bindings
-- ============================================================================

config.keys = {
  -- Tab management
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },

  -- Pane management (split panes)
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- Pane navigation
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },

  -- Pane resizing
  { key = 'LeftArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },

  -- Copy/Paste
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },

  -- Font size
  { key = '+', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },

  -- Search
  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },

  -- Scrollback
  { key = 'PageUp', mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },

  -- Toggle fullscreen
  { key = 'F11', mods = 'NONE', action = wezterm.action.ToggleFullScreen },

  -- Command Palette
  { key = 'p', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateCommandPalette },
}

-- ============================================================================
-- Launch Menu (Windows-specific shell profiles)
-- ============================================================================

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe' }

  config.launch_menu = {
    {
      label = 'PowerShell Core',
      args = { 'pwsh.exe' },
    },
    {
      label = 'Windows PowerShell',
      args = { 'powershell.exe' },
    },
    {
      label = 'Command Prompt',
      args = { 'cmd.exe' },
    },
    {
      label = 'Git Bash',
      args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' },
    },
    {
      label = 'Ubuntu (WSL)',
      args = { 'wsl.exe', '~' },
    },
  }
end

-- ============================================================================
-- Mouse Bindings
-- ============================================================================

config.mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },

  -- Right click paste from clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

-- ============================================================================
-- Hyperlink Rules
-- ============================================================================

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Make username/project paths clickable (GitHub style)
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = 'https://www.github.com/$1/$3',
})

return config
