vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true
opt.numberwidth = 2

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.smartindent = true

opt.wrap = false

-- Search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.hlsearch = true -- highlight search results
opt.incsearch = true -- show incremental search results

-- Visual enhancements for minimalist rice
opt.cursorline = true
opt.cursorlineopt = "number" -- only highlight the line number, not the entire line

-- Colors and UI
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- Transparency and blending for rice aesthetics
opt.pumblend = 10 -- transparency for popup menu
opt.winblend = 10 -- transparency for floating windows

-- Enhanced completion
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.shortmess:append("c") -- don't show redundant messages from ins-completion-menu

-- Better splits
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom
opt.splitkeep = "screen" -- keep the screen steady when splitting

-- Performance and file handling
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Scrolling and movement
opt.scrolloff = 8 -- keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- keep 8 columns left/right of cursor
opt.smoothscroll = true -- smooth scrolling

-- Better command line
opt.cmdheight = 1 -- command line height
opt.showmode = false -- don't show mode in command line (lualine shows it)

-- Better search and replace
opt.gdefault = true -- use global flag by default in s/// commands

-- Folding (minimal setup)
opt.foldmethod = "indent"
opt.foldlevel = 99 -- start with all folds open
opt.foldlevelstart = 99

-- Mouse support
opt.mouse = "a" -- enable mouse support
opt.mousefocus = true -- focus follows mouse

-- Better diff
opt.diffopt:append("iwhite") -- ignore whitespace in diff mode
opt.diffopt:append("algorithm:patience")
opt.diffopt:append("indent-heuristic")

-- Minimal list characters for clean look
opt.list = false -- don't show list characters by default
opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "·",
}

-- Session and view options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.viewoptions = { "folds", "options", "cursor", "unix", "slash" }

-- Better timeout settings
opt.timeoutlen = 300 -- time to wait for a mapped sequence to complete
opt.updatetime = 200 -- faster completion (4000ms default)

-- Better wildmenu
opt.wildmenu = true
opt.wildignorecase = true
opt.wildmode = { "longest:full", "full" }

-- Clipboard integration (commented for now)
-- opt.clipboard:append("unnamedplus") -- use system clipboard as default register
