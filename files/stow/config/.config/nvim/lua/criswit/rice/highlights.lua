local M = {}

-- Dark color palette for minimalist rice
local colors = {
  bg = "#0F111A",
  bg_alt = "#1B1E2B",
  bg_accent = "#212335",
  fg = "#EEFFFF",
  fg_alt = "#B2CCD6",
  grey = "#546E7A",
  grey_dark = "#37474F",
  blue = "#82AAFF",
  blue_dark = "#1976D2",
  purple = "#C792EA",
  cyan = "#89DDFF",
  green = "#C3E88D",
  yellow = "#FFCB6B",
  orange = "#F78C6C",
  red = "#FF5370",
  pink = "#F07178",
  transparent = "NONE",
}

-- Setup custom highlights
function M.setup_custom_highlights()
  local highlights = {
    -- Window and UI elements
    Normal = { bg = colors.bg, fg = colors.fg },
    NormalFloat = { bg = colors.bg_accent, fg = colors.fg },
    FloatBorder = { bg = colors.transparent, fg = colors.grey },
    WinSeparator = { fg = colors.grey_dark, bg = colors.transparent },
    
    -- Popup and completion menus
    Pmenu = { bg = colors.bg_accent, fg = colors.fg_alt },
    PmenuSel = { bg = colors.blue_dark, fg = colors.fg },
    PmenuSbar = { bg = colors.grey_dark },
    PmenuThumb = { bg = colors.grey },
    
    -- Bufferline specific highlights
    BufferLineFill = { bg = colors.bg_alt },
    BufferLineBuffer = { bg = colors.bg_alt, fg = colors.fg_alt },
    BufferLineBufferSelected = { bg = colors.bg, fg = colors.blue, bold = true },
    BufferLineBufferVisible = { bg = colors.bg_accent, fg = colors.fg_alt },
    BufferLineSeparator = { fg = colors.bg, bg = colors.bg_alt },
    BufferLineSeparatorSelected = { fg = colors.bg_alt, bg = colors.bg },
    BufferLineSeparatorVisible = { fg = colors.bg_alt, bg = colors.bg_accent },
    
    -- Indent guides
    IndentBlanklineIndent1 = { fg = colors.grey_dark },
    IndentBlanklineIndent2 = { fg = colors.grey_dark },
    IndentBlanklineContextChar = { fg = colors.grey },
    
    -- Telescope borderless
    TelescopeBorder = { fg = colors.bg, bg = colors.bg },
    TelescopeNormal = { bg = colors.bg },
    TelescopePreviewBorder = { fg = colors.bg, bg = colors.bg },
    TelescopePreviewNormal = { bg = colors.bg },
    TelescopeResultsBorder = { fg = colors.bg, bg = colors.bg },
    TelescopeResultsNormal = { bg = colors.bg },
    TelescopePromptBorder = { fg = colors.bg_accent, bg = colors.bg_accent },
    TelescopePromptNormal = { bg = colors.bg_accent },
    TelescopePromptPrefix = { fg = colors.blue },
    
    -- Git signs
    GitSignsAdd = { fg = colors.green },
    GitSignsChange = { fg = colors.yellow },
    GitSignsDelete = { fg = colors.red },
    
    -- LSP and diagnostics
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.cyan },
    DiagnosticHint = { fg = colors.green },
    
    -- nvim-tree borderless
    NvimTreeNormal = { bg = colors.bg, fg = colors.fg_alt },
    NvimTreeWinSeparator = { fg = colors.bg, bg = colors.bg },
    NvimTreeRootFolder = { fg = colors.blue, bold = true },
    NvimTreeFolderIcon = { fg = colors.blue },
    NvimTreeFileIcon = { fg = colors.fg_alt },
    NvimTreeOpenedFile = { fg = colors.green, bold = true },
    
    -- Statusline enhancements
    StatusLine = { bg = colors.bg_alt, fg = colors.fg },
    StatusLineNC = { bg = colors.bg_accent, fg = colors.grey },
  }
  
  -- Apply highlights
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Setup minimal window fill characters
function M.setup_fillchars()
  vim.opt.fillchars = {
    vert = "│",
    fold = "⠀",
    eob = " ", -- suppress ~ at EndOfBuffer
    diff = "╱", -- alternatives: ⣿ ░ ╱
    msgsep = "‾",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸"
  }
end

-- Apply transparency settings
function M.apply_transparency()
  -- Floating window transparency
  vim.opt.winblend = 10
  -- Popup menu transparency
  vim.opt.pumblend = 10
end

-- Get color palette for use in other modules
function M.get_colors()
  return colors
end

return M